# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
def default_password
  "123456"
end

def create_user(email, first_name, last_name)
  user = User.find_by(email: email)
  if user.nil?
    user = User.create(
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: default_password)
  end
  user
end

def create_pet(name, species, birthdate, insulin_frequency)
  pet = Pet.find_by(name: name)
  if pet.nil?
    pet = Pet.create!(name: name, species: species, birthdate: birthdate, insulin_frequency: insulin_frequency)
  end
  pet
end

def create_pet_owner(user, pet, ownership_level)
  unless PetOwner.exists?(owner_id: user.id, pet: pet)
    PetOwner.create!(owner_id: user.id, pet: pet, ownership_level: ownership_level)
  end
end

janderson = create_user("jandersonangelo@hotmail.com", "Janderson", "Angelo")
natalia = create_user("nataliam.baldan@gmail.com", "Natália", "Baldan")
matheus = create_user("matheusoliveira@gmail.com", "Matheus", "Oliveira")

jasmin = create_pet("Jasmin", "CAT", "2012-01-01", 12)

create_pet_owner(janderson, jasmin, "OWNER")
create_pet_owner(natalia, jasmin, "CARETAKER")
create_pet_owner(matheus, jasmin, "CARETAKER")