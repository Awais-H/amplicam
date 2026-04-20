module Auth
  class JsonWebToken
    ALGORITHM = "HS256".freeze

    class << self
      def encode(user)
        exp = Time.current.to_i + expiry_seconds
        payload = {
          "sub" => user.id,
          "email" => user.email,
          "name" => user.display_name,
          "exp" => exp,
          "iat" => Time.current.to_i
        }
        JWT.encode(payload, secret, ALGORITHM)
      end

      def decode(token)
        JWT.decode(token, secret, true, { algorithm: ALGORITHM }).first
      rescue JWT::DecodeError, JWT::ExpiredSignature
        nil
      end

      def expiry_seconds
        ENV.fetch("JWT_EXPIRY_HOURS", "168").to_i.hours.to_i
      end

      private

      def secret
        ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base }
      end
    end
  end
end
