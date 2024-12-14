class Invoice < ActiveRecord::Base
  has_many :payment_intents

  validates :amount, :subscription_id, presence: true

  def status
    return 'pending' if payment_intents.empty?

    return 'paid' if charge_amount == amount
    return 'partially_paid' if charge_amount < amount && charge_amount.positive?

    'failure'
  end

  def last_decline_code
    return if payment_intents.success.present?

    payment_intents.failure.last&.decline_code
  end

  def charge_amount
    payment_intents.success.sum(:amount)
  end
end
