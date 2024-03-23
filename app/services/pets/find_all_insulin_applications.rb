module Pets
  class FindAllInsulinApplications
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)

      find_insulin_applications
    end

    private

    def find_insulin_applications
      InsulinApplication.where(filters).order(application_time: :desc)
    end

    def filters
      filter_hash = {
        pet_id: pet_id
      }

      filter_hash[:application_time] = min_date..max_date if min_date || max_date
      filter_hash[:insulin_units] = min_units..max_units if min_units || max_units
      filter_hash[:glucose_level] = min_glucose..max_glucose if min_glucose || max_glucose

      filter_hash
    end

    def pet_id
      @params[:pet_id]
    end

    def user_id
      @decoded_token[:user_id]
    end

    def min_date
      @params[:min_date]
    end

    def max_date
      @params[:max_date]
    end

    def min_units
      @params[:min_units]
    end

    def max_units
      @params[:max_units]
    end

    def min_glucose
      @params[:min_glucose]
    end

    def max_glucose
      @params[:max_glucose]
    end

    def page
      @params[:page]
    end

    def per_page
      @params[:per_page]
    end
  end
end