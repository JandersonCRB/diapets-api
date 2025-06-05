module InsulinApplications
  # Service class for retrieving filter ranges for insulin applications
  # Calculates min/max values for dates, insulin units, and glucose levels
  # Used to provide UI filter boundaries for insulin application data
  class GetFilters
    prepend SimpleCommand
    include Helpers::PetAuthorizationHelpers

    # Initialize the filter service with authentication token and parameters
    # @param decoded_token [Hash] Decoded JWT token containing user information
    # @param params [Hash] Request parameters containing pet_id
    def initialize(decoded_token, params)
      Rails.logger.info "InsulinApplications::GetFilters initialized for user_id: #{decoded_token[:user_id]}, pet_id: #{params[:pet_id]}"
      @decoded_token = decoded_token
      @params = params
    end

    # Main execution method that validates authorization and returns filter ranges
    # Performs multiple validation checks before calculating filter values
    # @return [Hash] Filter ranges including min/max values for dates, units, and glucose levels
    def call
      Rails.logger.info "Starting filter calculation process for pet ID: #{pet_id}"
      
      # Validate that the pet exists
      validate_pet_existence(pet_id)
      Rails.logger.debug "Validated pet existence for pet ID: #{pet_id}"
      
      # Verify user has permission to access this pet's data
      validate_pet_permission(@decoded_token[:user_id], pet_id)
      Rails.logger.info "Authorization validated for user #{@decoded_token[:user_id]} to access pet #{pet_id} data"
      
      # Ensure insulin applications exist for this pet
      validate_insulin_application_existence(pet_id)
      Rails.logger.debug "Validated insulin application existence for pet ID: #{pet_id}"

      # Calculate and return filter ranges
      filter_results = filters
      Rails.logger.info "Successfully calculated filters for pet ID: #{pet_id}"
      Rails.logger.debug "Filter results: #{filter_results}"
      
      filter_results
    rescue => e
      Rails.logger.error "Failed to get filters for pet #{pet_id}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end

    private

    # Validate that insulin applications exist for the given pet
    # @param pet_id [String, Integer] The pet ID to check
    # @raise [Exceptions::NotFoundError] If no insulin applications exist for the pet
    def validate_insulin_application_existence(pet_id)
      Rails.logger.debug "Checking for insulin application existence for pet ID: #{pet_id}"
      
      return if InsulinApplication.exists?(pet_id: pet_id)

      Rails.logger.warn "No insulin applications found for pet ID: #{pet_id}"
      raise Exceptions::NotFoundError.new("Insulin application not found")
    end

    # Calculate filter ranges by querying min/max values from insulin applications
    # Uses aggregate functions to determine boundaries for filtering
    # @return [Hash] Hash containing min/max values for dates, units, and glucose levels
    def filters
      Rails.logger.debug "Calculating filter ranges for pet ID: #{pet_id}"
      
      # Execute aggregation query to get min/max values for all relevant fields
      insulin_application = InsulinApplication.select('min(application_time) as min_date')
                                              .select('max(application_time) as max_date')
                                              .select('min(insulin_units) as min_units')
                                              .select('max(insulin_units) as max_units')
                                              .select('min(glucose_level) as min_glucose')
                                              .select('max(glucose_level) as max_glucose')
                                              .where(pet_id: pet_id)
                                              .order('max_date')
                                              .first
      
      # Handle case where no data is returned (should not happen due to previous validation)
      if insulin_application.nil?
        Rails.logger.error "Insulin application query returned nil for pet ID: #{pet_id}"
        raise Exceptions::InternalServerError.new("Insulin application not found")
      end

      Rails.logger.debug "Raw filter data retrieved for pet #{pet_id}: min_date=#{insulin_application.min_date}, max_date=#{insulin_application.max_date}"

      # Return structured filter data
      {
        min_date: insulin_application.min_date,
        max_date: insulin_application.max_date,
        min_units: insulin_application.min_units,
        max_units: insulin_application.max_units,
        min_glucose: insulin_application.min_glucose,
        max_glucose: insulin_application.max_glucose,
      }
    end

    # Extract pet ID from request parameters
    # @return [String, Integer] The pet ID
    def pet_id
      @params[:pet_id]
    end
  end
end