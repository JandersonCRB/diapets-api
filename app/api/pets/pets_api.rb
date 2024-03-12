module Pets
  class PetsAPI < Grape::API
    helpers APIHelpers
    namespace :pets do
      desc 'Get pet list'
      get '' do
        user_authenticate!
        pets = Pets::FindAllByUser.call(decoded_token, params).result

        present pets, with: Entities::PetEntity
      end
    end
  end
end