require 'swagger_helper'

describe 'PaymentIntent API' do
  def self.payment_intent_object
    {
      type: :object,
      properties: {
        payment_intent: {
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

  path '/payment_intents' do
    post 'Creates a payment intent' do
      tags 'PaymentIntents'
      consumes 'application/json'
      parameter name: :payment_intent, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number, format: :float },
          subscription_id: { type: :integer }
        },
        required: [ 'amount', 'subscription_id' ]
      }

      response '201', 'payment_intent created' do
        schema payment_intent_object

        let(:payment_intent) { { amount: 100, subscription_id: 1 } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:payment_intent) { { amount: 100 } }
        run_test!
      end
    end
  end

  path '/payment_intents/{id}' do
    get 'Retrieves a payment_intent' do
      tags 'PaymentIntents'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'payment_intent found' do
        schema payment_intent_object

        let(:payment_intent) { create(:payment_intent) }
        let(:id) { payment_intent.id }
        run_test!
      end

      response '404', 'payment_intent not found' do
        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
