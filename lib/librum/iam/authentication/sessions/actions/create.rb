# frozen_string_literal: true

require 'cuprum/rails/action'
require 'stannum/contracts/hash_contract'

module Librum::Iam::Authentication::Sessions::Actions
  # Action for creating an authentication session.
  class Create < Cuprum::Rails::Action
    # Contract for validating the request parameters.
    CONTRACT =
      Stannum::Contracts::HashContract
      .new(allow_extra_keys: true) do
        key 'username',
          Stannum::Constraints::Presence.new(message: "can't be blank")
        key 'password',
          Stannum::Constraints::Presence.new(message: "can't be blank")
      end
      .freeze

    validate_parameters(CONTRACT)

    private

    def build_response(token)
      { 'token' => token }
    end

    def default_command_class
      Librum::Iam::Authentication::Sessions::Commands::Create
    end

    def validate_parameters(contract)
      match, errors = contract.match(params)

      return success(nil) if match

      error =
        Librum::Iam::Authentication::Errors::InvalidLogin.new(errors: errors)

      failure(error)
    end
  end
end
