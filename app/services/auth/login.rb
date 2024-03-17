module Auth
  class Login
    prepend SimpleCommand

    def initialize(params)
      @params = params
    end

    def call
      user = find_user
      validate_password(user)

      {
        token: generate_token(user),
        user: user
      }
    end

    private

    def find_user
      user = User.find_by(email: @params[:email])
      raise Exceptions::NotFoundError if user.nil?

      user
    end

    def validate_password(user)
      raise Exceptions::InvalidCredentialsError if user.authenticate(@params[:password]) == false
    end

    def generate_token(user)
      Jwt::Encode.call({ user_id: user.id }).result
    end

    def jwt_secret
      secret = ENV.fetch('JWT_SECRET', nil)

      raise Exceptions::InternalServerError.new("JWT_SECRET ENV VARIABLE NOT SET") if secret.nil?

      secret
    end
  end
end