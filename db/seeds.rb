# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

default_password = "123456"

janderson = User.find_by(email: "jandersonangelo@hotmail.com")
if janderson.nil?
  janderson = User.create(
    first_name: "Janderson",
    last_name: "Angelo",
    email: "jandersonangelo@hotmail.com",
    password: default_password)
end

naty = User.find_by(email: "nataliam.baldan@gmail.com")
if naty.nil?
  naty = User.create(
    first_name: "Natália",
    last_name: "Baldan",
    email: "nataliam.baldan@gmail.com",
    password: default_password)
end

matheus = User.find_by(email: "matheusoliveira@gmail.com")
if matheus.nil?
  matheus = User.create(
    first_name: "Matheus",
    last_name: "Oliveira",
    email: "matheusoliveira@gmail.com",
    password: default_password)
end

jasmin = Pet.find_by(name: "Jasmin")

if jasmin.nil?
  jasmin = Pet.create!(name: "Jasmin", species: "CAT", birthdate: "2012-01-01")
end

unless PetOwner.exists?(user: janderson, pet: jasmin)
  PetOwner.create!(user: janderson, pet: jasmin, ownership_level: "OWNER")
end

unless PetOwner.exists?(user: naty, pet: jasmin)
  PetOwner.create!(user: naty, pet: jasmin, ownership_level: "CARETAKER")
end

unless PetOwner.exists?(user: matheus, pet: jasmin)
  PetOwner.create!(user: matheus, pet: jasmin, ownership_level: "CARETAKER")
end