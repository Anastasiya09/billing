class PaymentIntent < ActiveRecord::Base
  enum :status, [
    :success,
    :failure
  ]

  belongs_to :invoice

  validates :amount, :invoice, :status, presence: true
end
