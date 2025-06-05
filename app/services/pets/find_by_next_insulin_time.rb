# frozen_string_literal: true

module Pets
  # Service class for finding pets that need insulin based on timing criteria
  # Used for notification system to identify pets requiring insulin doses
  class FindByNextInsulinTime
    prepend SimpleCommand

    # Initialize the service with timing and filtering parameters
    # @param params [Hash] Parameters for insulin timing search criteria
    def initialize(params)
      Rails.logger.info("Pets::FindByNextInsulinTime initialized with params: #{params.inspect}")
      @params = params
    end

    # Main execution method for finding pets needing insulin
    # Returns pets that meet the insulin timing criteria
    # @return [ActiveRecord::Relation] Pets that need insulin based on timing
    def call
      Rails.logger.info("Finding pets needing insulin with criteria: #{timing_criteria_summary}")

      pets = find_pet

      Rails.logger.info("Found #{pets.size} pets needing insulin")
      pets
    end

    private

    attr_reader :user

    # Complex query to find pets that need insulin based on timing criteria
    # Considers insulin frequency, last application time, and notification history
    # @return [ActiveRecord::Relation] Pets matching insulin timing criteria
    def find_pet
      Rails.logger.debug('Building complex query for pets needing insulin')

      pets = build_base_query
      pets = apply_late_pets_constraint(pets)
      apply_joins(pets)
    end

    # Builds the base query with timing calculations and notification constraints
    # @return [ActiveRecord::Relation] Base query for pets needing insulin
    def build_base_query
      Pet.select(:id, 'insulin_applications.id AS insulin_application_id')
         .where('pets.id not IN(:excluded_pets)', { excluded_pets: excluded_pets })
         .where("EXTRACT(EPOCH FROM NOW() at time zone 'utc' - " \
                'latest_applications.latest_application_time) / 60 >= ' \
                '(pets.insulin_frequency * 60) - :minutes_until_next_insulin',
                { minutes_until_next_insulin: minutes_until_next_insulin })
         .where('NOT EXISTS (SELECT 1 FROM sent_notifications WHERE sent_notifications.pet_id = pets.id ' \
                'AND sent_notifications.minutes_alarm = :minutes_until_next_insulin ' \
                'AND insulin_applications.id = sent_notifications.last_insulin_id)',
                { minutes_until_next_insulin: minutes_until_next_insulin })
    end

    # Applies constraint to exclude late pets if not specifically looking for them
    # @param pets [ActiveRecord::Relation] Base pets query
    # @return [ActiveRecord::Relation] Query with late pets constraint applied
    def apply_late_pets_constraint(pets)
      return pets if find_late_pets?

      Rails.logger.debug('Adding constraint to exclude late pets')
      pets.where("EXTRACT(EPOCH FROM NOW() at time zone 'utc' - " \
                 'latest_applications.latest_application_time) / 60 < ' \
                 '(pets.insulin_frequency * 60)')
    end

    # Applies joins with latest application times and insulin applications
    # @param pets [ActiveRecord::Relation] Base pets query with constraints
    # @return [ActiveRecord::Relation] Final query with all necessary joins
    def apply_joins(pets)
      pets.joins("INNER JOIN (
          SELECT pet_id, MAX(application_time) AS latest_application_time
          FROM insulin_applications
          GROUP BY pet_id
      ) AS latest_applications ON pets.id = latest_applications.pet_id")
          .joins("INNER JOIN
            insulin_applications ON
                insulin_applications.pet_id = pets.id AND
                insulin_applications.application_time = latest_applications.latest_application_time")
    end

    # Creates a summary of timing criteria for logging
    # @return [String] Human-readable timing criteria summary
    def timing_criteria_summary
      criteria = []
      criteria << "minutes_until_next: #{minutes_until_next_insulin}"
      criteria << "find_late_pets: #{find_late_pets?}"
      criteria << "excluded_pets: #{excluded_pets.size} pets" unless excluded_pets == [0]
      criteria.join(', ')
    end

    # Gets the minutes until next insulin threshold from parameters
    # Used to determine how far in advance to notify about upcoming insulin
    # @return [Integer] Minutes until next insulin (defaults to 0 for immediate notifications)
    def minutes_until_next_insulin
      @params[:minutes_until_next_insulin] || 0
    end

    # Gets the list of pet IDs to exclude from the search
    # Returns [0] as default to prevent SQL errors with empty IN clause
    # @return [Array<Integer>] Pet IDs to exclude from results
    def excluded_pets
      if @params[:excluded_pets].blank?
        return [0] # Use [0] to prevent SQL errors with empty IN clause
      end

      @params[:excluded_pets]
    end

    # Determines whether to include pets with overdue insulin applications
    # When true, includes pets that are already late for their insulin
    # @return [Boolean] Whether to find late pets (defaults to false)
    def find_late_pets?
      @params[:find_late_pets] || false
    end
  end
end
