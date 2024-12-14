class Invoice < ActiveRecord::Base
  PENDING = 'pending'
  PAID = 'paid'
  PARTIALLY_PAID = 'partially_paid'
  FAILURE = 'failure'

  has_many :payment_intents

  validates :amount, :subscription_id, presence: true

  def status
    return PENDING if payment_intents.empty?

    return PAID if charge_amount == amount
    return PARTIALLY_PAID if charge_amount < amount && charge_amount.positive?

    FAILURE
  end

  def last_decline_code
    return if payment_intents.success.present?

    payment_intents.failure.last&.decline_code
  end

  def charge_amount
    payment_intents.success.sum(:amount)
  end
end
