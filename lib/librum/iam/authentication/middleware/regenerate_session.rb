# frozen_string_literal: true

require 'cuprum/middleware'

module Librum::Iam::Authentication::Middleware
  # Middleware for updating the session with the current user.
  class RegenerateSession < Cuprum::Command
    include Cuprum::Middleware

    private

    attr_reader :request

    def extract_token(value)
      return unless value.is_a?(Hash)

      value['token']
    end

    def native_session
      request.native_session
    end

    def process(next_command, request:)
      @request = request
      result   = next_command.call(request: request)

      return result unless result.success?

      token = extract_token(result.value)

      write_session(token) if token.present?

      result
    end

    def write_session(token)
      native_session['auth_token'] = token
    end
  end
end
