require 'rails_helper'

RSpec.describe Charge::CreateWorker do
  describe 'perform' do
    subject(:perform) { described_class.new.perform(payment_intent.id, amount) }

    let(:payment_intent) { create(:payment_intent, amount: 100) }
    let(:amount) { 100 }
    let(:payment_provider_instance) { instance_double(ExternalPaymentProvider, call: result) }
    let(:result) { { status: :success } }

    before do
      allow(ExternalPaymentProvider).to receive(:new).and_return(payment_provider_instance)
      allow(described_class).to receive(:perform_in)
    end

    it 'creates a charge' do
      expect { perform }.to change { Charge.count }.by(1)
      expect(Charge.first).to have_attributes(
        payment_intent: payment_intent,
        amount: amount,
        status: 'success',
        decline_code: nil,
        error_message: nil
      )
    end

    it 'does not call next worker' do
      perform
      expect(described_class).not_to have_received(:perform_in)
    end

    context 'when partially paid' do
      let(:amount) { 50 }

      it 'creates a charge' do
        expect { perform }.to change { Charge.count }.by(1)
        expect(Charge.first).to have_attributes(
          payment_intent: payment_intent,
          amount: amount,
          status: 'success',
          decline_code: nil,
          error_message: nil
        )
      end

      it 'calls worker one week later for remaining balance' do
        perform
        expect(described_class).to have_received(:perform_in).with(1.week, payment_intent.id, 50)
      end
    end

    context 'when ExternalPaymentProvider returns failed result' do
      let(:result) { { status: :failure, decline_code: :insufficient_funds, error_message: 'error message' } }

      it 'creates a charge' do
        expect { perform }.to change { Charge.count }.by(1)
        expect(Charge.first).to have_attributes(
          payment_intent: payment_intent,
          amount: amount,
          status: 'failure',
          decline_code: 'insufficient_funds',
          error_message: 'error message'
        )
      end

      it 'calls worker for one rebill with the same amount' do
        perform
        expect(described_class).to have_received(:perform_in).with(30.second, payment_intent.id, 100)
      end

      context 'when percent value should be changed' do
        before do
          create_list(:charge, 3, payment_intent: payment_intent, amount: 100, status: :failure)
        end

        it 'creates a charge' do
          expect { perform }.to change { Charge.count }.by(1)
          expect(Charge.last).to have_attributes(
            payment_intent: payment_intent,
            amount: amount,
            status: 'failure',
            decline_code: 'insufficient_funds',
            error_message: 'error message'
          )
        end

        it 'calls worker for one rebill with persent of amount' do
          perform
          expect(described_class).to have_received(:perform_in).with(30.second, payment_intent.id, 75)
        end
      end

      context 'when decline_code is not insufficient_funds' do
        let(:result) { { status: :failure, decline_code: :card_not_supported, error_message: 'error message' } }

        it 'creates a charge' do
          expect { perform }.to change { Charge.count }.by(1)
          expect(Charge.first).to have_attributes(
            payment_intent: payment_intent,
            amount: amount,
            status: 'failure',
            decline_code: 'card_not_supported',
            error_message: 'error message'
          )
        end

        it 'does not call worker' do
          perform
          expect(described_class).not_to have_received(:perform_in)
        end
      end
    end
  end
end
