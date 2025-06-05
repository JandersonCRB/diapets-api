# frozen_string_literal: true

module Pets
  # Service class for retrieving pet dashboard information
  # Provides insulin application history and next dose scheduling data
  class Dashboard
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the dashboard service with authentication and pet parameters
    # @param decoded_token [Hash] JWT token containing user authentication data
    # @param params [Hash] Parameters containing pet_id for dashboard data
    def initialize(decoded_token, params)
      Rails.logger.info("Pets::Dashboard initialized for user_id: #{decoded_token[:user_id]}, pet_id: #{params[:pet_id]}")
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method for retrieving dashboard data
    # Validates user permissions and returns insulin application data
    # @return [Hash] Dashboard data with last and next insulin application info
    def call
      Rails.logger.info("Fetching dashboard data for pet_id: #{pet_id}")

      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)

      dashboard_data = {
        last_insulin_application: last_insulin_application,
        next_insulin_application: next_insulin_application
      }

      Rails.logger.info("Dashboard data retrieved successfully for pet_id: #{pet_id}")
      dashboard_data
    end

    private

    # Retrieves the most recent insulin application for the pet
    # Uses memoization to prevent multiple database queries
    # @return [InsulinApplication, nil] The last insulin application or nil if none exist
    def last_insulin_application
      Rails.logger.debug("Fetching last insulin application for pet_id: #{pet_id}")
      @last_insulin_application ||= InsulinApplication.where(pet_id: pet_id).order(application_time: :desc).first
    end

    # Calculates the next scheduled insulin application time
    # Based on the last application time and pet's insulin frequency
    # @return [Time, nil] The next insulin application time or nil if no previous application
    def next_insulin_application
      Rails.logger.debug("Calculating next insulin application time for pet_id: #{pet_id}")

      pet_insulin_frequency = Pet.select(:insulin_frequency).find(pet_id).insulin_frequency
      next_time = last_insulin_application&.application_time&.advance(hours: pet_insulin_frequency)

      Rails.logger.debug("Next insulin application calculated: #{next_time}")
      next_time
    end

    # Extracts pet_id from request parameters
    # @return [Integer] The pet ID from parameters
    def pet_id
      @params[:pet_id]
    end

    # Extracts user_id from decoded JWT token
    # @return [Integer] The user ID from authentication token
    def user_id
      @decoded_token[:user_id]
    end
  end
end
