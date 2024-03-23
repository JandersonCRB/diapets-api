module InsulinApplications
  class GetFilters
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_pet_existence(pet_id)
      validate_pet_permission(@decoded_token[:user_id], pet_id)
      validate_insulin_application_existence(pet_id)

      filters
    end

    private

    def validate_insulin_application_existence(pet_id)
      return if InsulinApplication.exists?(pet_id: pet_id)

      raise Exceptions::NotFoundError.new("Insulin application not found")
    end

    def filters
      insulin_application = InsulinApplication.select('min(application_time) as min_date')
                                              .select('max(application_time) as max_date')
                                              .select('min(insulin_units) as min_units')
                                              .select('max(insulin_units) as max_units')
                                              .select('min(glucose_level) as min_glucose')
                                              .select('max(glucose_level) as max_glucose')
                                              .where(pet_id: pet_id)
                                              .order('max_date')
                                              .first
      raise Excpetions::InternalServerError.new("Insulin application not found") if insulin_application.nil?

      {
        min_date: insulin_application.min_date,
        max_date: insulin_application.max_date,
        min_units: insulin_application.min_units,
        max_units: insulin_application.max_units,
        min_glucose: insulin_application.min_glucose,
        max_glucose: insulin_application.max_glucose,
      }
    end

    def pet_id
      @params[:pet_id]
    end
  end
end