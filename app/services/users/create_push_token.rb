module Users
  class CreatePushToken
    prepend SimpleCommand

    def initialize(decoded_token, params)
      @decoded_token = decoded_token
      @params = params
    end

    def call
      create_push_token(user)
    end

    private

    def user
      @user ||= User.find(@decoded_token[:user_id])
    end

    def create_push_token(user)
      PushToken.find_or_create_by!(user: user, token: @params[:token])
    end
  end
end