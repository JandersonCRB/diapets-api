module Pets
  class FindByNextInsulinTime
    prepend SimpleCommand

    def initialize(params)
      @params = params
    end

    def call
      find_pet
    end

    private

    attr_reader :user

    def find_pet
      pets = Pet.select(:id, 'insulin_applications.id AS insulin_application_id')
         .where("pets.id not IN(:excluded_pets)", {excluded_pets: excluded_pets})
         .where("EXTRACT(EPOCH FROM NOW() at time zone 'utc' - latest_applications.latest_application_time) / 60 >= (pets.insulin_frequency * 60) - :minutes_until_next_insulin", {minutes_until_next_insulin: minutes_until_next_insulin})
         .where("NOT EXISTS (SELECT 1 FROM sent_notifications WHERE sent_notifications.pet_id = pets.id AND sent_notifications.minutes_alarm = :minutes_until_next_insulin AND insulin_applications.id = sent_notifications.last_insulin_id)", {minutes_until_next_insulin: minutes_until_next_insulin})
      unless find_late_pets?
        pets = pets.where("EXTRACT(EPOCH FROM NOW() at time zone 'utc' - latest_applications.latest_application_time) / 60 < (pets.insulin_frequency * 60)")
      end
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

    def minutes_until_next_insulin
      @params[:minutes_until_next_insulin] || 0
    end

    def excluded_pets
      if @params[:excluded_pets].nil? || @params[:excluded_pets].empty?
        return [0]
      end
      @params[:excluded_pets]
    end

    def find_late_pets?
      @params[:find_late_pets] || false
    end
  end
end