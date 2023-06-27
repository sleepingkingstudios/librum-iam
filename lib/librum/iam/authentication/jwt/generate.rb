# frozen_string_literal: true

require 'cuprum'
require 'jwt'

require 'librum/iam/authentication/jwt'

module Librum::Iam::Authentication::Jwt
  # Generates a JWT from an authorization session.
  class Generate < Cuprum::Command
    private

    def process(session)
      payload = {
        exp: session.expires_at.to_i,
        sub: session.credential.id
      }

      JWT.encode(payload, secret, 'HS512')
    end

    def secret
      Rails.application.secret_key_base
    end
  end
end
