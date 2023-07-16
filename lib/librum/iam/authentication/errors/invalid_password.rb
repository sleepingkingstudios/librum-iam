# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Error returned when a password does not match the encrypted value.
  class InvalidPassword < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.invalid_password'

    # @param message [String] message describing the nature of the error.
    def initialize(message: nil, **options)
      super(
        message: message || default_message,
        **options
      )
    end

    private

    def default_message
      'password does not match encrypted value'
    end
  end
end
