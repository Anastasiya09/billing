require 'rails_helper'

RSpec.describe PaymentIntent, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:charges) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:subscription_id) }
  end

  describe '#charge_amount' do
    subject { payment_intent.charge_amount }

    let(:payment_intent) { create(:payment_intent) }

    before do
      create(:charge, payment_intent: payment_intent, amount: 100, status: :success)
      create(:charge, payment_intent: payment_intent, amount: 200, status: :failure)
    end

    it { is_expected.to eq 100 }
  end

  describe '#last_decline_code' do
    subject { payment_intent.last_decline_code }

    let(:payment_intent) { create(:payment_intent) }

    context 'when failure status is present' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 100, status: :failure, decline_code: 'card_declined', created_at: 1.day.ago)
        create(:charge, payment_intent: payment_intent, amount: 200, status: :failure, decline_code: 'insufficient_funds')
      end

      it { is_expected.to eq 'insufficient_funds' }
    end

    context 'when no failure status' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 100, status: :success)
      end

      it { is_expected.to be nil }
    end

    context 'when last status is success' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 100, status: :failure, decline_code: 'card_declined', created_at: 1.day.ago)
        create(:charge, payment_intent: payment_intent, amount: 100, status: :success)
      end

      it { is_expected.to be nil }
    end
  end

  describe '#status' do
    subject { payment_intent.status }

    let(:payment_intent) { create(:payment_intent, amount: 100) }

    context 'when no charges' do
      it { is_expected.to eq described_class::PENDING }
    end

    context 'when charge amount is equal to payment_intent amount' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 100, status: :success)
      end

      it { is_expected.to eq described_class::PAID }
    end

    context 'when charge amount is less than payment_intent amount' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 50, status: :success)
      end

      it { is_expected.to eq described_class::PARTIALLY_PAID }
    end

    context 'when only failed charges' do
      before do
        create(:charge, payment_intent: payment_intent, amount: 50, status: :failure)
      end

      it { is_expected.to eq described_class::FAILURE }
    end
  end
end
