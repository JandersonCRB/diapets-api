class PetOwner < ApplicationRecord
  OWNERSHIP_LEVELS = %w(OWNER CARETAKER)

  belongs_to :pet
  belongs_to :owner, foreign_key: :owner_id, class_name: 'User'

  validates :pet_id, presence: true
  validates :owner_id, presence: true
  validates :ownership_level, presence: true, inclusion: { in: OWNERSHIP_LEVELS }
end