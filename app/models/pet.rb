# frozen_string_literal: true

# Represents a diabetic pet in the system (dogs or cats).
# Each pet can have multiple owners/caretakers and maintains a history
# of insulin applications. Pets have an insulin frequency that determines
# how often they need insulin shots.
class Pet < ApplicationRecord
  has_many :pet_owners, dependent: :destroy
  has_many :owners, through: :pet_owners, source: :owner, dependent: :destroy
  has_many :insulin_applications, dependent: :destroy

  SPECIES = %w[DOG CAT].freeze

  validates :name, presence: true
  validates :species, presence: true, inclusion: { in: SPECIES }

  # insulin_frequency is the number of hours between insulin shots
  validates :insulin_frequency, presence: true, numericality: { only_integer: true, greater_than: 0 }
end
