# frozen_string_literal: true

require 'cuprum'
require 'jwt'

require 'librum/iam/authentication/errors/expired_token'
require 'librum/iam/authentication/errors/invalid_token'
require 'librum/iam/authentication/errors/malformed_token'
require 'librum/iam/authentication/jwt'

module Librum::Iam::Authentication::Jwt
  # Generates a session from an encoded JWT.
  class Parse < Cuprum::Command
    private

    def decode_token(token)
      payload, = JWT.decode(token, secret, true, algorithm: 'HS512')

      payload
    rescue JWT::ExpiredSignature
      failure(Librum::Iam::Authentication::Errors::ExpiredToken.new)
    rescue JWT::IncorrectAlgorithm
      failure(Librum::Iam::Authentication::Errors::InvalidToken.new)
    rescue JWT::DecodeError
      failure(Librum::Iam::Authentication::Errors::MalformedToken.new)
    end

    def process(token)
      step { validate_token(token) }

      payload = step { decode_token(token) }

      {
        'credential_id' => payload['sub'],
        'expires_at'    => payload['exp']
      }
    end

    def secret
      Rails.application.secret_key_base
    end

    def validate_token(token)
      return if token.is_a?(String) && !token.empty?

      failure(Librum::Iam::Authentication::Errors::MalformedToken.new)
    end
  end
end
