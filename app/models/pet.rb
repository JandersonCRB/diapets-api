class Pet < ApplicationRecord
  has_many :pet_owners
  has_many :owners, through: :pet_owners, source: :owner

  SPECIES = %w(DOG CAT)

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }
end
