# frozen_string_literal: true

require 'cuprum/middleware'

module Librum::Iam::Authentication::Middleware
  # Middleware for authenticating the current user from the request.
  class AuthenticateRequest < Cuprum::Command
    include Cuprum::Middleware

    # @param repository [Cuprum::Collections::Repository] The repository used to
    #   query the user and credential.
    # @param resource [Cuprum::Rails::Resource] The controller resource.
    def initialize(repository:, resource:)
      super()

      @repository = repository
      @resource   = resource
    end

    # @return [Cuprum::Collections::Repository] the repository used to query the
    #   user and credential.
    attr_reader :repository

    # @return [Cuprum::Rails::Resource] the controller resource.
    attr_reader :resource

    private

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

    def process(next_command, request:)
      return super if skip_authentication?(request)

      session = step { authenticate_request(request) }
      request = build_request(request: request, session: session)

      next_command.call(request: request)
    end

    def skip_authentication?(request)
      return false unless resource.respond_to?(:skip_authentication_for?)

      resource.skip_authentication_for?(request.action_name)
    end
  end
end
