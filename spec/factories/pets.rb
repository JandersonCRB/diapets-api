FactoryBot.define do
  factory :pet do
    name { Faker::Creature::Cat.name }
    species { Pet::SPECIES.sample }
    birthdate { "2024-03-11" }
    insulin_frequency { 12 }
    owners { [] }
  end
end
