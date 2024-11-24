FactoryBot.define do
  factory :shipment do
    association :order, factory: :order
    shipment_status { %w[pending shipped delivered canceled].sample }
    carrier { %w[UPS FedEx DHL].sample }
    tracking_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    shipped_at { shipment_status == "shipped" ? Faker::Time.backward(days: 3) : nil }
    delivered_at { shipment_status == "delivered" ? Faker::Time.backward(days: 1) : nil }
  end
end
