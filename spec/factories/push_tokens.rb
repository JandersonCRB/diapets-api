FactoryBot.define do
  factory :push_token do
    user { create(:user) }
    token { Faker::Alphanumeric.alphanumeric(number: 32) }
  end
end
