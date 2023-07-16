# frozen_string_literal: true

module Librum::Iam::Authentication::Errors
  # Error returned when a user does not have a password credential.
  class MissingPassword < Librum::Core::Errors::AuthenticationError
    # Short string used to identify the type of error.
    TYPE = 'librum.iam.authentication.errors.missing_password'

    # @param user_id [String] the primary key of the user.
    def initialize(user_id:, **options)
      @user_id = user_id

      super(
        user_id: user_id,
        message: default_message,
        **options
      )
    end

    # @return [String] the primary key of the user.
    attr_reader :user_id

    private

    def as_json_data
      { 'user_id' => user_id }
    end

    def default_message
      "password credential not found for user with id: #{user_id.inspect}"
    end
  end
end
