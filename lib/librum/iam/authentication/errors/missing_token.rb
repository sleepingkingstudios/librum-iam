# frozen_string_literal: true

require 'librum/iam/authentication/errors'

module Librum::Iam::Authentication::Errors
  # Error returned when an authentication token is not provided.
  class MissingToken < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.missing_token'

    def initialize
      super(message: 'missing authentication token')
    end
  end
end
