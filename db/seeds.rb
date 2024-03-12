# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# display sql queries
ActiveRecord::Base.logger = Logger.new(STDOUT)

janderson = User.find_by(email: "jandersonangelo@hotmail.com")
if janderson.nil?
  janderson = User.create(
    first_name: "Janderson",
    last_name: "Angelo",
    email: "jandersonangelo@hotmail.com",
    password: "123456")
end

jasmin = Pet.find_by(name: "Jasmin")

if jasmin.nil?
  jasmin = Pet.create!(name: "Jasmin", species: "CAT", birthdate: "2012-01-01")
end

unless PetOwners.exists?(user: janderson, pet: jasmin)
  PetOwners.create!(user: janderson, pet: jasmin, ownership_level: "OWNER")
end