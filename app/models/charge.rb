class Charge < ActiveRecord::Base
  enum :status, [
    :success,
    :failure
  ]

  belongs_to :payment_intent

  validates :amount, :payment_intent, :status, presence: true
end
