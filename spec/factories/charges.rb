FactoryBot.define do
  factory :charge do
    amount { 100 }
    payment_intent
    status { :success }
  end
end
