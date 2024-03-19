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
      pets_needing_insulin = Pet.find_by_sql(["
      SELECT pets.id
      FROM pets
      INNER JOIN (
          SELECT pet_id, MAX(application_time) AS latest_application_time
          FROM insulin_applications
          GROUP BY pet_id
      ) AS latest_applications ON pets.id = latest_applications.pet_id
      WHERE
      pets.id not IN(:excluded_pets) and
      EXTRACT(EPOCH FROM NOW() at time zone 'utc' - latest_applications.latest_application_time) / 60 >= (pets.insulin_frequency * 60) - :minutes_until_next_insulin
      #{find_late_pets? ? '' : "and EXTRACT(EPOCH FROM NOW() at time zone 'utc' - latest_applications.latest_application_time) / 60 < (pets.insulin_frequency * 60)"}
      ", {excluded_pets: excluded_pets, minutes_until_next_insulin: minutes_until_next_insulin}])
      pets_needing_insulin.each do |pet|
        puts pet
        puts "#{pet.id} needs insulin within the next #{minutes_until_next_insulin} minutes."
      end
      pets_needing_insulin
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