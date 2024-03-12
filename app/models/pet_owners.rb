class PetOwners < ApplicationRecord
  OWNERSHIP_LEVELS = %w(OWNER CARETAKER)

  belongs_to :pet
  belongs_to :user, foreign_key: :owner_id

  validates :ownership_level, presence: true, inclusion: { in: OWNERSHIP_LEVELS }
end