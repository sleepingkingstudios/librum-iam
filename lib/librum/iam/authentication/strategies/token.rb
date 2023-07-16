# frozen_string_literal: true

require 'cuprum'

module Librum::Iam::Authentication::Strategies
  # Authentication strategy for parsing an encoded JWT.
  class Token < Cuprum::Command
    class << self
      # @return true if the strategy is valid for the request; otherwise false.
      def matches?(_request)
        false
      end
      alias match? matches?
    end

    # @param repository [Cuprum::Collections::Repository] The repository used to
    #   query the credential.
    def initialize(repository:)
      super()

      @repository = repository
    end

    # @return [Cuprum::Collections::Repository] the repository used to query the
    #   credential.
    attr_reader :repository

    private

    attr_reader :request

    def build_session(credential:, payload:)
      expires_at = Time.zone.at(payload['expires_at'])

      Librum::Iam::Session.new(
        credential: credential,
        expires_at: expires_at
      )
    end

    def credentials_collection
      repository.find_or_create(record_class: Librum::Iam::Credential)
    end

    def find_credential(credential_id:)
      result = credentials_collection.find_one.call(primary_key: credential_id)

      return result.value if result.success?

      failure(
        Librum::Iam::Authentication::Errors::MissingCredential
          .new(credential_id: credential_id)
      )
    end

    def find_token
      nil
    end

    def parse_token(token)
      Librum::Iam::Authentication::Jwt::Parse.new.call(token)
    end

    def process(request)
      @request = request

      token      = step { require_token }
      payload    = step { parse_token(token) }

      step { validate_token(payload) }

      credential = step do
        find_credential(credential_id: payload['credential_id'])
      end

      step { validate_credential(credential) }

      build_session(credential: credential, payload: payload)
    end

    def require_token
      token = find_token

      return token if token.present?

      failure(Librum::Iam::Authentication::Errors::MissingToken.new)
    end

    def validate_credential(credential)
      return unless credential.expired?

      failure(
        Librum::Iam::Authentication::Errors::ExpiredCredential
          .new(credential_id: credential.id)
      )
    end

    def valid_token?(payload)
      return false unless payload['credential_id'].is_a?(String)

      return false unless payload['expires_at'].is_a?(Integer)

      true
    end

    def validate_token(payload)
      return if valid_token?(payload)

      failure(Librum::Iam::Authentication::Errors::InvalidToken.new)
    end
  end
end
