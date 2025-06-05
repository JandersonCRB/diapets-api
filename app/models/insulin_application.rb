# frozen_string_literal: true

# Records individual insulin administrations for diabetic pets.
# Each application tracks when insulin was given to a specific pet by a user,
# helping maintain treatment history and schedule adherence.
class InsulinApplication < ApplicationRecord
  belongs_to :user
  belongs_to :pet
end
