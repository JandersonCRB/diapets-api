# frozen_string_literal: true

class InsulinApplication < ApplicationRecord
  belongs_to :user
  belongs_to :pet
end
