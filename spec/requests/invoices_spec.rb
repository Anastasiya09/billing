require 'swagger_helper'

describe 'Invoces API' do
  def self.invoice_object
    {
      type: :object,
      properties: {
        invoice: {
          type: :object,
          properties: {
            id: { type: :integer },
            amount: { type: :number, format: :float },
            subscription_id: { type: :integer },
            status: { type: :string },
            charge_amount: { type: :number, format: :float },
            last_decline_code: { type: :string, nullable: true }
          },
          required: [ 'id', 'amount', 'subscription_id', 'status', 'charge_amount', 'last_decline_code' ]
        }
      }
    }
  end

  path '/invoices' do
    post 'Creates a invoice' do
      tags 'Invoices'
      consumes 'application/json'
      parameter name: :invoice, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number, format: :float },
          subscription_id: { type: :integer }
        },
        required: [ 'amount', 'subscription_id' ]
      }

      response '201', 'invoice created' do
        schema invoice_object

        let(:invoice) { { amount: 100, subscription_id: 1 } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:invoice) { { amount: 100 } }
        run_test!
      end
    end
  end

  path '/invoices/{id}' do
    get 'Retrieves a invoice' do
      tags 'Invoices'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'invoice found' do
        schema invoice_object

        let(:invoice) { create(:invoice) }
        let(:id) { invoice.id }
        run_test!
      end

      response '404', 'invoice not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
