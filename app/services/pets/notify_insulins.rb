# frozen_string_literal: true

module Pets
  # Service class for notifying pet owners about upcoming insulin applications
  # Finds pets needing insulin and sends push notifications to their owners
  class NotifyInsulins
    prepend SimpleCommand

    # Initialize the notification service
    # No parameters required as it uses predefined notification settings
    def initialize
      Rails.logger.info('Pets::NotifyInsulins initialized')
    end

    # Main execution method for insulin notification process
    # Finds pets needing insulin, sends notifications, and logs the sent notifications
    # @return [void]
    def call
      Rails.logger.info('Starting insulin notification process')

      pet_ids = find_pet_ids

      if pet_ids.empty?
        Rails.logger.info('No pets found needing insulin notifications')
        return
      end

      notify_all(pet_ids)
      log_notifications(pet_ids)

      Rails.logger.info("Insulin notification process completed for #{pet_ids.size} pets")
    end

    private

    # Default parameters for finding pets that need insulin notifications
    # Sets notification threshold to 15 minutes before next insulin is due
    # @return [Hash] Parameters for pet search criteria
    def params
      {
        minutes_until_next_insulin: 15,  # Notify 15 minutes before insulin is due
        find_late_pets: false,           # Don't include overdue pets
        excluded_pets: []                # No pets excluded by default
      }
    end

    # Finds pets that need insulin notifications based on timing criteria
    # Uses FindByNextInsulinTime service to identify pets requiring notifications
    # @return [ActiveRecord::Relation] Pets that need insulin notifications
    def find_pet_ids
      Rails.logger.info("Finding pets that need insulin notifications with params: #{params}")

      pets = FindByNextInsulinTime.call(params).result
      Rails.logger.info("Found pets needing notifications: #{pets.to_json}")

      pets
    end

    # Sends push notifications to all owners of pets needing insulin
    # Collects push tokens from pet owners and sends notifications
    # @param pet_ids [ActiveRecord::Relation] Pets requiring insulin notifications
    def notify_all(pet_ids)
      Rails.logger.info("Sending notifications to owners of #{pet_ids.count} pets")

      pets = load_pets_with_owners(pet_ids)
      process_pet_notifications(pets)
    end

    # Load pets with their owners and push tokens
    # @param pet_ids [ActiveRecord::Relation] Pet IDs to load
    # @return [ActiveRecord::Relation] Pets with included associations
    def load_pets_with_owners(pet_ids)
      Pet.select(:id, :name).includes(owners: :push_tokens).where(id: pet_ids.map(&:id))
    end

    # Process notifications for each pet
    # @param pets [ActiveRecord::Relation] Pets to process
    def process_pet_notifications(pets)
      pets.each do |pet|
        Rails.logger.debug { "Processing notifications for pet: #{pet.name} (ID: #{pet.id})" }
        push_tokens = collect_push_tokens_for_pet(pet)
        notify_users(push_tokens, pet.name) if push_tokens.any?
      end
    end

    # Collect push tokens for a specific pet
    # @param pet [Pet] The pet to collect tokens for
    # @return [Array<String>] Array of push tokens
    def collect_push_tokens_for_pet(pet)
      push_tokens = []
      pet.owners.each do |owner|
        owner.push_tokens.each do |push_token|
          push_tokens << push_token.token
        end
      end
      Rails.logger.debug { "Collected #{push_tokens.size} push tokens for pet #{pet.name}" }
      push_tokens
    end

    # Sends push notification to specific users about a pet's insulin needs
    # @param push_tokens [Array<String>] Push notification tokens for target users
    # @param pet_name [String] Name of the pet needing insulin
    def notify_users(push_tokens, pet_name)
      Rails.logger.info("Sending push notifications for pet: #{pet_name} to #{push_tokens.size} devices")

      PushNotifications::NotifyUsers.call(push_tokens,
                                          "#{pet_name}: Insulina!",
                                          "#{pet_name} precisará de insulina em breve!.")

      Rails.logger.info("Push notifications sent successfully for pet: #{pet_name}")
    end

    # Logs notification records to prevent duplicate notifications
    # Creates SentNotification records to track when notifications were sent
    # @param pet_ids [ActiveRecord::Relation] Pets for which notifications were sent
    def log_notifications(pet_ids)
      Rails.logger.info("Logging notification records for #{pet_ids.count} pets")

      pet_ids.each do |pet|
        Rails.logger.debug { "Creating notification log for pet_id: #{pet.id}" }

        SentNotification.create(pet_id: pet.id,
                                minutes_alarm: params[:minutes_until_next_insulin],
                                last_insulin_id: pet.insulin_application_id)
      end

      Rails.logger.info('Notification logging completed')
    end
  end
end
