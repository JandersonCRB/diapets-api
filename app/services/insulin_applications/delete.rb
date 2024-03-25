module InsulinApplications
  class Delete
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(token, params)
      @token = token
      @params = params
    end

    def call
      insulin_application = find_insulin_application

      validate_pet_permission(user_id, insulin_application.pet_id)

      insulin_application.destroy
    end

    private

    def insulin_application_id
      @params[:insulin_application_id]
    end

    def user_id
      @token[:user_id]
    end

    def find_insulin_application
      InsulinApplication.find_by!(id: insulin_application_id)
    rescue ActiveRecord::RecordNotFound
      raise Exceptions::NotFoundError.new('Insulin application not found')
    end

  end
end