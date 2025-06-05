# frozen_string_literal: true

# Base ActiveRecord class that serves as the parent for all application models.
# This abstract class inherits from ActiveRecord::Base and provides common
# functionality and configuration for all models in the Diapets API.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
