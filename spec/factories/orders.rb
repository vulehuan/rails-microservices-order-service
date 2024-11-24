FactoryBot.define do
  factory :order do
    order_number { "ORD#{Faker::Number.unique.number(digits: 6)}" }
    user_id { 2 }
    status { %w[pending completed canceled].sample }
    shipping_address_line1 { Faker::Address.street_address }
    shipping_address_line2 { Faker::Address.secondary_address }
    shipping_city { Faker::Address.city }
    shipping_state { Faker::Address.state }
    shipping_zip_code { Faker::Address.zip_code }
    shipping_country { Faker::Address.country }
    recipient_name { Faker::Name.name }
    recipient_phone { Faker::PhoneNumber.cell_phone_in_e164 }
    order_notes { [Faker::Lorem.sentence(word_count: 10), nil].sample }
    admin_notes { [Faker::Lorem.sentence(word_count: 8), nil].sample }
    created_at { Faker::Time.backward(days: 30) }
    updated_at { Faker::Time.backward(days: 5) }
    total_price { 0.0 }
  end
end
