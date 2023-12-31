# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Abstract error returned for an malformed authentication token.
  class MalformedToken < Librum::Iam::Authentication::Errors::InvalidToken
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.malformed_token'

    private

    def default_message
      'malformed authentication token'
    end
  end
end
