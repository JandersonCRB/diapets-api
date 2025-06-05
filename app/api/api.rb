# frozen_string_literal: true

# Main API entry point for the Diapets application
# Configures the API prefix, format, and mounts all API endpoints
class API < Grape::API
  prefix 'api/v1'
  format :json

  mount Base
  add_swagger_documentation
end
