# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Error returned for a failed username+password login.
  class InvalidLogin < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.invalid_login'

    # @param errors [Stannum::Errors] the errors object, if any.
    def initialize(errors: nil)
      super(
        errors:  errors,
        message: 'invalid username or password'
      )

      @errors = errors
    end

    # @return [Stannum::Errors] the errors object, if any.
    attr_reader :errors

    private

    def as_json_data
      return {} unless errors

      { 'errors' => errors.as_json }
    end
  end
end
