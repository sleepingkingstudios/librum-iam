# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Abstract error returned for an invalid authentication token.
  class InvalidToken < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.invalid_token'

    # @param message [String] Message describing the nature of the error.
    def initialize(message: nil, **options)
      super(
        message: message || default_message,
        **options
      )
    end

    private

    def default_message
      'invalid authentication token'
    end
  end
end
