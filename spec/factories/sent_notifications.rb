FactoryBot.define do
  factory :sent_notification do
    pet { create(:pet) }
    minutes_left { 15 }
    last_insulin { create(:insulin_application) }
  end
end
