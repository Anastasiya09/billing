require 'rails_helper'

RSpec.describe Charge, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:payment_intent) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:payment_intent) }
    it { is_expected.to validate_presence_of(:status) }
  end
end
