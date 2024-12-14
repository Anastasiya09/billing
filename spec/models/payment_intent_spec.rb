require "rails_helper"

RSpec.describe PaymentIntent, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:invoice) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:invoice) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
