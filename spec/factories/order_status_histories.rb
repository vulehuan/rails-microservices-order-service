FactoryBot.define do
  factory :order_status_history do
    association :order
    status { %w[pending processing shipped delivered canceled].sample }
    note { [Faker::Lorem.sentence(word_count: 6), nil].sample }
  end
end
