# frozen_string_literal: true

require 'cuprum/rails/action'
require 'stannum/contracts/hash_contract'

module Librum::Iam::Actions::Sessions
  # Action for creating an authentication session.
  class Create < Cuprum::Rails::Action
    CONTRACT = Stannum::Contracts::HashContract.new(allow_extra_keys: true) do
      key 'username',
        Stannum::Constraints::Presence.new(message: "can't be blank")
      key 'password',
        Stannum::Constraints::Presence.new(message: "can't be blank")
    end
    private_constant :CONTRACT

    private

    def build_token(session)
      Librum::Iam::Authentication::Jwt::Generate.new.call(session)
    end

    def find_credential
      Librum::Iam::Authentication::Passwords::Find
        .new(repository: repository)
        .call(username: params['username'], password: params['password'])
    end

    def process(request:)
      super

      step { validate_parameters }

      credential = step { find_credential }
      session    = Librum::Iam::Session.new(credential: credential)
      token      = step { build_token(session) }

      { 'token' => token }
    end

    def validate_parameters
      match, errors = CONTRACT.match(params)

      return success(nil) if match

      error =
        Librum::Iam::Authentication::Errors::InvalidLogin.new(errors: errors)

      failure(error)
    end
  end
end
