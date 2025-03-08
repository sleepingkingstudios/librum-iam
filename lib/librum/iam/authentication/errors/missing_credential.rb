# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Error returned when parsing a token without the specified credential.
  class MissingCredential < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.missing_credential'

    # @param credential_id [String] The primary key of the missing credential.
    def initialize(credential_id:, **)
      @credential_id = credential_id

      super(
        credential_id: credential_id,
        message:       default_message,
        **
      )
    end

    # @return [String] the primary key of the missing credential.
    attr_reader :credential_id

    private

    def as_json_data
      { 'credential_id' => credential_id }
    end

    def default_message
      "credential not found with id: #{credential_id.inspect}"
    end
  end
end
