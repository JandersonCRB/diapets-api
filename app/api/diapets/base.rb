module Diapets
  class Base < Grape::API
    get do
      { hello: 'world' }
    end
  end
end