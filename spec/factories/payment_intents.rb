FactoryBot.define do
  factory :payment_intent do
    amount { 100 }
    subscription_id { 1 }
  end
end
