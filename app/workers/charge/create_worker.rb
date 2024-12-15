class Charge::CreateWorker
  REBILLING_RULES = [
    { range: 0..3, percent: 100 },
    { range: 4..7, percent: 75 },
    { range: 8..11, percent: 50 },
    { range: 11..15, percent: 25 }
  ]
  FAILURE_RETRY_DELAY = 30.seconds
  SUCCESS_REBILLING_DELAY = 1.week

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(payment_intent_id, amount)
    @payment_intent = PaymentIntent.find(payment_intent_id)
    @amount = amount

    result = ExternalPaymentProvider.new(amount).call # some data get from PaymentIntent, like: currency, user_id, card_info, etc.
    create_charge(result)
    call_next_charge_creation
  end

  private

  attr_reader :payment_intent, :amount, :charge

  def create_charge(result)
    @charge = Charge.create!(
      payment_intent: payment_intent,
      amount: amount,
      status: result[:status],
      decline_code: result[:decline_code],
      error_message: result[:error_message]
    )
  end

  def call_next_charge_creation
    return if charge.success? && charge.amount == payment_intent.amount

    if charge.success?
      # automatically schedule an additional transaction one week later for the remaining balance.
      Charge::CreateWorker.perform_in(
        SUCCESS_REBILLING_DELAY,
        payment_intent.id,
        payment_intent.amount - payment_intent.charge_amount
      )
    elsif charge.decline_code == 'insufficient_funds'
      next_amount_charge = payment_intent.amount * percent / 100
      Charge::CreateWorker.perform_in(FAILURE_RETRY_DELAY, payment_intent.id, next_amount_charge) if next_amount_charge.positive?
    end
  end

  def percent
    charges_count = payment_intent.charges.count
    REBILLING_RULES.find { |i| i[:range].include?(charges_count) }&.dig(:percent) || 0
  end
end
