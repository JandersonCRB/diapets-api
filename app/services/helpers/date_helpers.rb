module Helpers
  module DateHelpers
    def date_valid?(date)
      Date.parse(date)
    rescue
      false
    end

    def date_in_future?(date)
      Date.parse(date) > Date.today
    end
  end
end