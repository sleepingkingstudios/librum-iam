# frozen_string_literal: true

require 'cuprum/middleware'

module Librum::Iam::Authentication::Middleware
  # Middleware for authenticating the current user from the session.
  class AuthenticateSession < Cuprum::Command
    include Cuprum::Middleware

    private

    attr_reader \
      :repository,
      :resource

    def authenticate_request(request)
      Librum::Iam::Authentication::Strategies::SessionToken
        .new(repository: repository)
        .call(request.native_session)
    end

    def build_request(request:, session:)
      Librum::Iam::Request.new(
        context: request.context,
        session: session,
        **request.properties
      )
    end

    def merge_result(result:, session:)
      metadata = result.respond_to?(:metadata) ? (result.metadata || {}) : {}

      Cuprum::Rails::Result.new(
        error:    result.error,
        metadata: metadata.merge(session: session),
        status:   result.status,
        value:    result.value
      )
    end

    def process(next_command, repository:, request:, resource:, **rest) # rubocop:disable Metrics/MethodLength
      @repository = repository
      @resource   = resource

      return super if skip_authentication?(request)

      session = step { authenticate_request(request) }
      request = build_request(request: request, session: session)
      result  = next_command.call(
        repository: repository,
        request:    request,
        resource:   resource,
        **rest
      )

      merge_result(result: result, session: session)
    end

    def skip_authentication?(request)
      return false unless resource.respond_to?(:skip_authentication_for?)

      resource.skip_authentication_for?(request.action_name)
    end
  end
end
