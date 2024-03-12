FactoryBot.define do
  factory :insulin_application do
    glucose_level { 1 }
    insulin_units { 1 }
    user_id { nil }
    application_time { "2024-03-11 21:59:43" }
    observations { "MyString" }
    pet_id { nil }
  end
end
