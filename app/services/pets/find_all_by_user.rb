module Pets
  class FindAllByUser
    prepend SimpleCommand

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      validate_user_existence
      Pet.includes(:owners).where(owners: { id: user_id })
    end

    private

    def user_id
      @user_id ||= @decoded_token[:user_id]
    end

    def validate_user_existence
      return if User.exists?(user_id)

      raise Exceptions::InternalServerError, 'User not found'
    end
  end
end