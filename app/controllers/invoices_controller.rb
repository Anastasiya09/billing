class InvoicesController < ApplicationController
  def create
    @invoice = Invoice.create!(invoice_params)
    PaymentIntent::CreateWorker.perform_async(invoice.id, invoice.amount)
    render json: invoice_response, status: :created
  end

  def show
    render json: invoice_response
  end

  private

  def invoice
    @invoice ||= Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:amount, :subscription_id)
  end

  def invoice_response
    {
      invoice: {
        id: invoice.id,
        amount: invoice.amount,
        subscription_id: invoice.subscription_id,
        status: invoice.status,
        charge_amount: invoice.charge_amount,
        last_decline_code: invoice.last_decline_code
      }
    }
  end
end
