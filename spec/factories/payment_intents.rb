FactoryBot.define do
  factory :payment_intent do
    amount { 100 }
    invoice
    status { :success }
  end
end
