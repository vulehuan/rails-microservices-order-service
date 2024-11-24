FactoryBot.define do
  factory :order_item do
    association :order
    product_id { Faker::Number.number(digits: 5) }
    quantity { Faker::Number.between(from: 1, to: 10) }
    unit_price { Faker::Commerce.price(range: 10..100) }
    total_price { quantity * unit_price }
  end
end
