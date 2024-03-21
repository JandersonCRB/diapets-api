module Pets
  class NotifyInsulins
    prepend SimpleCommand

    def initialize
    end

    def call
      Rails.logger.info("Notifying insulins")
      pet_ids = find_pet_ids

      notify_all(pet_ids)
      log_notifications(pet_ids)
    end

    private

    def params
      {
        minutes_until_next_insulin: 15,
        find_late_pets: false,
        excluded_pets: []
      }
    end

    def find_pet_ids
      pets = FindByNextInsulinTime.call(params).result
      Rails.logger.info("pets: #{pets.to_json}")

      pets
    end

    def notify_all(pet_ids)
      pets = Pet.select(:id, :name).includes(owners: :push_tokens).where(id: pet_ids.map(&:id))
      pets.each do |pet|
        push_tokens = []
        pet.owners.each do |owner|
          owner.push_tokens.each do |push_token|
            push_tokens << push_token.token
          end
        end
        notify_users(push_tokens, pet.name)
      end
    end

    def notify_users(push_tokens, pet_name)
      puts "Notifying users"
      PushNotifications::NotifyUsers.call(push_tokens,
                                          "#{pet_name}: Insulina!",
                                          "#{pet_name} precisará de insulina em breve!.")
    end

    def log_notifications(pet_ids)
      pet_ids.each do |pet|
        SentNotification.create(pet_id: pet.id,
                                minutes_alarm: params[:minutes_until_next_insulin],
                                last_insulin_id: pet.insulin_application_id)
      end
    end
  end
end