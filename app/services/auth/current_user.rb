module Auth
  class CurrentUser
    prepend SimpleCommand
    include Helpers::EnvHelpers

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      user = User.find_by(id: @decoded_token[:user_id])
      raise Exceptions::NotFoundError.new, 'User not found' if user.nil?
      user
    end
  end
end