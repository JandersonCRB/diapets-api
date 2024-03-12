class Pet < ApplicationRecord
  has_many :users, through: :pet_owners
  SPECIES = %w(DOG CAT)

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
end
