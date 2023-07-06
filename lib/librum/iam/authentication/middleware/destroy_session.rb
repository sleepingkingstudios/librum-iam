# frozen_string_literal: true

require 'cuprum/middleware'

require 'librum/iam/authentication/middleware'

module Librum::Iam::Authentication::Middleware
  # Middleware for clearing the authentication session.
  class DestroySession < Cuprum::Command
    include Cuprum::Middleware

    private

    attr_reader :request

    def clear_session
      native_session.delete('auth_token')
    end

    def native_session
      request.native_session
    end

    def process(next_command, request:)
      @request = request
      result   = next_command.call(request: request)

      clear_session

      result
    end
  end
end
