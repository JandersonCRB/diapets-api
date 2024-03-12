class InsulinApplication < ApplicationRecord
  belongs_to :user_id
  belongs_to :pet_id
end
