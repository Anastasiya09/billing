class ExternalPaymentProvider
  # data is any additional data related to payment
  def initialize(amount, data = {})
    @amount = amount
    @data = data
  end

  def call
    # call external billing service. only for example
    { status: :success }
    # { status: :failure, decline_code: 'insufficient_funds' }
    # { status: :failure, decline_code: 'card_not_supported' }
    # raise 'External billing service is not available'
  rescue => e
    Rails.logger.fatal e
    { status: :failure, error_message: e }
  end
end
