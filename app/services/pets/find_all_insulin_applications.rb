# frozen_string_literal: true

module Pets
  # Service class for finding all insulin applications for a specific pet
  # Supports filtering by date range, insulin units, and glucose levels
  class FindAllInsulinApplications
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the service with authentication token and filter parameters
    # @param decoded_token [Hash] JWT token containing user authentication data
    # @param params [Hash] Filter parameters including pet_id and optional filters
    def initialize(decoded_token, params)
      Rails.logger.info("Pets::FindAllInsulinApplications initialized for user_id: #{decoded_token[:user_id]}, " \
                        "pet_id: #{params[:pet_id]}")
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method for retrieving filtered insulin applications
    # Validates user permissions and returns filtered insulin application records
    # @return [ActiveRecord::Relation] Filtered insulin applications ordered by application time
    def call
      Rails.logger.info("Finding insulin applications for pet_id: #{pet_id} with filters: #{filter_summary}")

      validate_pet_existence(pet_id)
      validate_pet_permission(user_id, pet_id)

      applications = find_insulin_applications

      Rails.logger.info("Found #{applications.count} insulin applications for pet_id: #{pet_id}")
      applications
    end

    private

    # Retrieves insulin applications based on applied filters
    # Orders results by application time in descending order (most recent first)
    # @return [ActiveRecord::Relation] Filtered and ordered insulin applications
    def find_insulin_applications
      Rails.logger.debug('Applying filters to insulin applications query')
      InsulinApplication.where(filters).order(application_time: :desc)
    end

    # Builds filter hash for insulin application queries
    # Dynamically adds filters based on provided parameters
    # @return [Hash] Filter conditions for the database query
    def filters
      Rails.logger.debug('Building filter conditions for insulin applications')

      filter_hash = {
        pet_id: pet_id
      }

      # Add date range filter if min or max date is provided
      filter_hash[:application_time] = min_date..max_date if min_date || max_date

      # Add insulin units range filter if min or max units is provided
      filter_hash[:insulin_units] = min_units..max_units if min_units || max_units

      # Add glucose level range filter if min or max glucose is provided
      filter_hash[:glucose_level] = min_glucose..max_glucose if min_glucose || max_glucose

      Rails.logger.debug("Filter conditions: #{filter_hash}")
      filter_hash
    end

    # Creates a summary of applied filters for logging purposes
    # @return [String] Human-readable filter summary
    def filter_summary
      filters = []
      filters << "date: #{min_date}..#{max_date}" if min_date || max_date
      filters << "units: #{min_units}..#{max_units}" if min_units || max_units
      filters << "glucose: #{min_glucose}..#{max_glucose}" if min_glucose || max_glucose
      filters.empty? ? 'none' : filters.join(', ')
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

    # Extracts minimum date filter from parameters
    # @return [Date, nil] Minimum date for filtering or nil if not provided
    def min_date
      @params[:min_date]
    end

    # Extracts maximum date filter from parameters
    # @return [Date, nil] Maximum date for filtering or nil if not provided
    def max_date
      @params[:max_date]
    end

    # Extracts minimum insulin units filter from parameters
    # @return [Numeric, nil] Minimum insulin units for filtering or nil if not provided
    def min_units
      @params[:min_units]
    end

    # Extracts maximum insulin units filter from parameters
    # @return [Numeric, nil] Maximum insulin units for filtering or nil if not provided
    def max_units
      @params[:max_units]
    end

    # Extracts minimum glucose level filter from parameters
    # @return [Numeric, nil] Minimum glucose level for filtering or nil if not provided
    def min_glucose
      @params[:min_glucose]
    end

    # Extracts maximum glucose level filter from parameters
    # @return [Numeric, nil] Maximum glucose level for filtering or nil if not provided
    def max_glucose
      @params[:max_glucose]
    end
  end
end
