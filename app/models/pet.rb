class Pet < ApplicationRecord
  has_many :pet_owners
  has_many :owners, through: :pet_owners, source: :owner

  SPECIES = %w(DOG CAT)

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }

  # insulin_frequency is the number of hours between insulin shots
  validates :insulin_frequency, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
