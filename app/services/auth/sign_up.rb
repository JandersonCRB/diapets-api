module Auth
  class SignUp
    prepend SimpleCommand
    include Helpers::AuthHelpers

    def initialize(params)
      @params = params
    end

    def call
      validate_email
      validate_password
      validate_names
      user = create_user
      token = generate_token(user)
      { :token => token, :user => user }
    end

    private

    def validate_email
      raise Exceptions::UnprocessableEntityError.new('Email is required', detailed_code: "EMAIL_REQUIRED") if @params[:email].blank?
      raise Exceptions::UnprocessableEntityError.new('Email is invalid', detailed_code: "INVALID_EMAIL") if @params[:email] !~ URI::MailTo::EMAIL_REGEXP

      raise Exceptions::UnprocessableEntityError.new('Email is already taken', detailed_code: "EMAIL_TAKEN") if User.exists?(email: @params[:email])
    end

    def create_user
      User.create(user_params)
    end

    def validate_password
      raise Exceptions::UnprocessableEntityError.new('Password is too short', detailed_code: "SHORT_PASSWORD") if @params[:password].length < 6
    end

    def validate_names
      raise Exceptions::UnprocessableEntityError.new('First name is required', detailed_code: "FIRST_NAME_REQUIRED") if @params[:first_name].blank?
      raise Exceptions::UnprocessableEntityError.new('First name is too short', detailed_code: "FIRST_NAME_SHORT") if @params[:first_name].length < 2
      raise Exceptions::UnprocessableEntityError.new('Last name is required', detailed_code: "LAST_NAME_REQUIRED") if @params[:last_name].blank?
      raise Exceptions::UnprocessableEntityError.new('Last name is too short', detailed_code: "LAST_NAME_SHORT") if @params[:last_name].length < 2
    end

    def user_params
      {
        email: @params[:email],
        password: @params[:password],
        first_name: @params[:first_name],
        last_name: @params[:last_name]
      }
    end
  end
end