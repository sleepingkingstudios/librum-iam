# frozen_string_literal: true

require 'cuprum/middleware'

module Librum::Iam::Authentication::Middleware
  # Middleware for authenticating the current user from the request.
  class AuthenticateRequest < Cuprum::Command
    include Cuprum::Middleware

    private

    attr_reader \
      :repository,
      :resource

    def authenticate_request(request)
      Librum::Iam::Authentication::Strategies::RequestToken
        .new(repository: repository)
        .call(request)
    end

    def build_request(request:, session:)
      Librum::Iam::Request.new(
        context: request.context,
        session: session,
        **request.properties
      )
    end

    def process(next_command, repository:, request:, resource:, **rest) # rubocop:disable Metrics/MethodLength
      @repository = repository
      @resource   = resource

      return super if skip_authentication?(request)

      session = step { authenticate_request(request) }
      request = build_request(request: request, session: session)

      next_command.call(
        repository: repository,
        request:    request,
        resource:   resource,
        **rest
      )
    end

    def skip_authentication?(request)
      return false unless resource.respond_to?(:skip_authentication_for?)

      resource.skip_authentication_for?(request.action_name)
    end
  end
end
