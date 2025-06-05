# frozen_string_literal: true

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
    rescue StandardError => e
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
        parsed_date, today = parse_date_and_today(date)
        compare_date_with_today(parsed_date, today)
      rescue StandardError => e
        handle_date_parsing_error(date, e)
      end
    end

    private

    # Parse the input date and get today's date
    # @param date [String] The date string to parse
    # @return [Array<Date>] Array containing parsed_date and today
    def parse_date_and_today(date)
      parsed_date = Date.parse(date)
      today = Time.zone.today
      Rails.logger.debug "Parsed date: #{parsed_date}, Today: #{today}"
      [parsed_date, today]
    end

    # Compare the parsed date with today's date
    # @param parsed_date [Date] The parsed date
    # @param today [Date] Today's date
    # @return [Boolean] True if the date is in the future
    def compare_date_with_today(parsed_date, today)
      is_future = parsed_date > today
      Rails.logger.debug "Date #{parsed_date} is #{is_future ? 'in the future' : 'not in the future'}"
      is_future
    end

    # Handle date parsing errors
    # @param date [String] The original date string
    # @param error [StandardError] The error that occurred
    # @raise [ArgumentError] Always raises with formatted message
    def handle_date_parsing_error(date, error)
      Rails.logger.error "Failed to parse date '#{date}' for future check: #{error.message}"
      raise ArgumentError, "Invalid date format: #{date}"
    end
  end
end
