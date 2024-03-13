module Helpers
  module PetAuthorizationHelpers
    def validate_pet_permission(user_id, pet_id, owner_permission: false)
      query_params = {
        owner_id: user_id,
        pet_id: pet_id,
      }

      query_params[:ownership_level] = "OWNER" if owner_permission
      return if PetOwner.exists?(query_params)

      raise Exceptions::UnauthorizedError.new
    end

    def validate_pet_existence(pet_id)
      return if Pet.exists?(id: pet_id)

      raise Exceptions::NotFoundError.new
    end
  end
end