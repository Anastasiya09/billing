class PaymentIntent < ActiveRecord::Base
  PENDING = 'pending'
  PAID = 'paid'
  PARTIALLY_PAID = 'partially_paid'
  FAILURE = 'failure'

  has_many :charges

  validates :amount, :subscription_id, presence: true

  def status
    return PENDING if charges.empty?

    return PAID if charge_amount == amount
    return PARTIALLY_PAID if charge_amount < amount && charge_amount.positive?

    FAILURE
  end

  def last_decline_code
    return if charges.success.present?

    charges.failure.last&.decline_code
  end

  def charge_amount
    charges.success.sum(:amount)
  end
end
