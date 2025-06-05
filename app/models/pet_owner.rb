# frozen_string_literal: true

class PetOwner < ApplicationRecord
  OWNERSHIP_LEVELS = %w[OWNER CARETAKER].freeze

  belongs_to :pet
  belongs_to :owner, class_name: 'User'

  validates :pet_id, presence: true
  validates :owner_id, presence: true
  validates :ownership_level, presence: true, inclusion: { in: OWNERSHIP_LEVELS }
end
