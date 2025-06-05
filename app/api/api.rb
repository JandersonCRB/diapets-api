# frozen_string_literal: true

class API < Grape::API
  prefix 'api/v1'
  format :json

  mount Base
  add_swagger_documentation
end
