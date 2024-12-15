class PaymentIntentsController < ApplicationController
  def create
    @payment_intent = PaymentIntent.create!(payment_intent_params)
    Charge::CreateWorker.perform_async(payment_intent.id, payment_intent.amount)
    render json: payment_intent_response, status: :created
  end

  def show
    render json: payment_intent_response
  end

  private

  def payment_intent
    @payment_intent ||= PaymentIntent.find(params[:id])
  end

  def payment_intent_params
    params.require(:payment_intent).permit(:amount, :subscription_id)
  end

  def payment_intent_response
    {
      payment_intent: {
        id: payment_intent.id,
        amount: payment_intent.amount,
        subscription_id: payment_intent.subscription_id,
        status: payment_intent.status,
        charge_amount: payment_intent.charge_amount,
        last_decline_code: payment_intent.last_decline_code
      }
    }
  end
end
