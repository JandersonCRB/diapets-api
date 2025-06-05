module Helpers
  # Helper module for date validation and manipulation operations
  # Provides utility methods for date parsing and validation
  module DateHelpers
    
    # Validate if a given string represents a valid date
    # Attempts to parse the date string and returns boolean result
    # @param date [String] The date string to validate
    # @return [Boolean] True if the date is valid, false otherwise
    def date_valid?(date)
      Rails.logger.debug "Validating date string: '#{date}'"
      
      # Attempt to parse the date string
      parsed_date = Date.parse(date)
      Rails.logger.debug "Successfully parsed date: #{parsed_date}"
      
      # Return true if parsing succeeds (implicit return)
      true
    rescue => e
      # Log parsing failure and return false
      Rails.logger.debug "Date validation failed for '#{date}': #{e.message}"
      false
    end

    # Check if a given date string represents a future date
    # Parses the date and compares it with today's date
    # @param date [String] The date string to check
    # @return [Boolean] True if the date is in the future, false otherwise
    # @raise [ArgumentError] If the date string cannot be parsed
    def date_in_future?(date)
      Rails.logger.debug "Checking if date '#{date}' is in the future"
      
      begin
        # Parse the input date
        parsed_date = Date.parse(date)
        today = Date.today
        
        Rails.logger.debug "Parsed date: #{parsed_date}, Today: #{today}"
        
        # Compare with today's date
        is_future = parsed_date > today
        Rails.logger.debug "Date #{parsed_date} is #{is_future ? 'in the future' : 'not in the future'}"
        
        is_future
      rescue => e
        Rails.logger.error "Failed to parse date '#{date}' for future check: #{e.message}"
        raise ArgumentError, "Invalid date format: #{date}"
      end
    end
  end
end