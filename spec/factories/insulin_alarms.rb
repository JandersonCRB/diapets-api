FactoryBot.define do
  factory :insulin_alarm do
    hour { 1 }
    minute { 1 }
    title { "MyString" }
    status { false }
    pet { nil }
  end
end
