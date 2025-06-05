# frozen_string_literal: true

# Join table model that defines ownership relationships between users and pets.
# Supports different ownership levels (OWNER or CARETAKER) to control
# access permissions and responsibilities for pet care management.
class PetOwner < ApplicationRecord
  OWNERSHIP_LEVELS = %w[OWNER CARETAKER].freeze

  belongs_to :pet
  belongs_to :owner, class_name: 'User'

  validates :pet_id, presence: true
  validates :owner_id, presence: true
  validates :ownership_level, presence: true, inclusion: { in: OWNERSHIP_LEVELS }
end
