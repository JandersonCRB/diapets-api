module Diapets
  class API < Grape::API
    prefix 'api/v1'
    format :json

    mount Diapets::Base
    add_swagger_documentation
  end
end