require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:payment_intents) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:subscription_id) }
  end

  describe '#charge_amount' do
    subject { invoice.charge_amount }

    let(:invoice) { create(:invoice) }

    before do
      create(:payment_intent, invoice: invoice, amount: 100, status: :success)
      create(:payment_intent, invoice: invoice, amount: 200, status: :failure)
    end

    it { is_expected.to eq 100 }
  end

  describe '#last_decline_code' do
    subject { invoice.last_decline_code }

    let(:invoice) { create(:invoice) }

    context 'when failure status is present' do
      before do
        create(:payment_intent, invoice: invoice, amount: 100, status: :failure, decline_code: 'card_declined', created_at: 1.day.ago)
        create(:payment_intent, invoice: invoice, amount: 200, status: :failure, decline_code: 'insufficient_funds')
      end

      it { is_expected.to eq 'insufficient_funds' }
    end

    context 'when no failure status' do
      before do
        create(:payment_intent, invoice: invoice, amount: 100, status: :success)
      end

      it { is_expected.to be nil }
    end

    context 'when last status is success' do
      before do
        create(:payment_intent, invoice: invoice, amount: 100, status: :failure, decline_code: 'card_declined', created_at: 1.day.ago)
        create(:payment_intent, invoice: invoice, amount: 100, status: :success)
      end

      it { is_expected.to be nil }
    end
  end

  describe '#status' do
    subject { invoice.status }

    let(:invoice) { create(:invoice, amount: 100) }

    context 'when no payment intents' do
      it { is_expected.to eq described_class::PENDING }
    end

    context 'when charge amount is equal to invoice amount' do
      before do
        create(:payment_intent, invoice: invoice, amount: 100, status: :success)
      end

      it { is_expected.to eq described_class::PAID }
    end

    context 'when charge amount is less than invoice amount' do
      before do
        create(:payment_intent, invoice: invoice, amount: 50, status: :success)
      end

      it { is_expected.to eq described_class::PARTIALLY_PAID }
    end

    context 'when only failed payment intents' do
      before do
        create(:payment_intent, invoice: invoice, amount: 50, status: :failure)
      end

      it { is_expected.to eq described_class::FAILURE }
    end
  end
end
