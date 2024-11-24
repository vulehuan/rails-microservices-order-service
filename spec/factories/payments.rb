FactoryBot.define do
  factory :payment do
    association :order
    payment_method { %w[credit_card paypal bank_transfer].sample }
    payment_status { %w[pending completed failed].sample }
    transaction_id { Faker::Alphanumeric.alphanumeric(number: 12).upcase }
    amount { Faker::Commerce.price(range: 50..1000) }
    paid_at { payment_status == "completed" ? Faker::Time.backward(days: 2) : nil }
  end
end
