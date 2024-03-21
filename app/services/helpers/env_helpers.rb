module Helpers
  module EnvHelpers
    def jwt_secret
      jwt = ENV.fetch('JWT_SECRET', nil)
      raise Exceptions::InternalServerError.new("JWT_SECRET ENV VARIABLE NOT SET") if jwt.nil?
      jwt
    end

    def fcm_cred_path
      fcm = ENV.fetch('FCM_CRED_PATH', nil)
      raise Exceptions::InternalServerError.new("FCM_CRED_PATH ENV VARIABLE NOT SET") if fcm.nil?
      fcm
    end

    def fcm_project_id
      fcm = ENV.fetch('FCM_PROJECT_ID', nil)
      raise Exceptions::InternalServerError.new("FCM_PROJECT_ID ENV VARIABLE NOT SET") if fcm.nil?
      fcm
    end
  end
end
