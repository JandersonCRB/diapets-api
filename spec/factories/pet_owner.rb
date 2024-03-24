FactoryBot.define do
  factory :pet_owner do
    owner_id { 1 }
    pet_id { 1 }
    ownership_level { PetOwner::OWNERSHIP_LEVELS.sample }
  end
end
