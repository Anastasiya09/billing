class Invoice < ActiveRecord::Base
  has_many :payment_intents

  validates :amount, :subscription_id, presence: true
end
