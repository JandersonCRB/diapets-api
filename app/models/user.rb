# frozen_string_literal: true

# Represents a user in the Diapets system who can own or care for diabetic pets.
# Users can have multiple pets through ownership relationships and receive
# push notifications on their registered devices about pet care reminders.
class User < ApplicationRecord
  has_many :push_tokens, dependent: :destroy
  has_many :pet_owners, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :pets, through: :pet_owners

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  has_secure_password
end
