FactoryBot.define do
  factory :pet do
    name { Faker::Creature::Cat.name }
    species { Pet::SPECIES.sample }
    birthdate { "2024-03-11" }
    owners { [] }
  end
end
