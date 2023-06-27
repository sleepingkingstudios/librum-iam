# frozen_string_literal: true

require 'librum/iam/authentication/errors'
require 'librum/iam/authentication/errors/invalid_token'

module Librum::Iam::Authentication::Errors
  # Abstract error returned for an expired authentication token.
  class ExpiredToken < Librum::Iam::Authentication::Errors::InvalidToken
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.expired_token'

    private

    def default_message
      'expired authentication token'
    end
  end
end
