class PaymentIntent::CreateWorker
  REBILLING_RULES = [
    { range: 0..3, percent: 100 },
    { range: 4..7, percent: 75 },
    { range: 8..11, percent: 50 },
    { range: 11..15, percent: 25 }
  ]

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(invoice_id, amount)
    @invoice = Invoice.find(invoice_id)
    @amount = amount

    result = ExternalBilling.new(amount).call # some data get from Invoice, like: currency, user_id, card_info, etc.
    create_payment_intent(result)
    call_next_payment_intent_creation
  end

  private

  attr_reader :invoice, :amount, :payment_intent

  def create_payment_intent(result)
    @payment_intent = PaymentIntent.create!(
      invoice: invoice,
      amount: amount,
      status: result[:status],
      decline_code: result[:decline_code],
      error_message: result[:error_message]
    )
  end

  def call_next_payment_intent_creation
    return if payment_intent.success? && payment_intent.amount == invoice.amount

    if payment_intent.success?
      # automatically schedule an additional transaction one week later for the remaining balance.
      PaymentIntent::CreateWorker.perform_in(1.week, invoice.id, invoice.amount - payment_intent.amount)
    else
      next_amount_charge = invoice.amount * percent / 100
      PaymentIntent::CreateWorker.perform_in(10.second, invoice.id, next_amount_charge) if next_amount_charge.positive?
    end
  end

  def percent
    payment_intents_count = invoice.payment_intents.count
    REBILLING_RULES.find { |i| i[:range].include?(payment_intents_count) }&.dig(:percent) || 0
  end
end
