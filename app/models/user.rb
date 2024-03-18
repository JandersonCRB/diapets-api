class User < ApplicationRecord
  has_many :push_tokens
  has_many :pet_owners, foreign_key: :owner_id
  has_many :pets, through: :pet_owners

  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  has_secure_password
end
