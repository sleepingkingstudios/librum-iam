# frozen_string_literal: true

module Librum::Iam::Authentication::Sessions::Commands
  # Creates an authentication session from a username and password.
  class Create < Cuprum::Rails::Command
    private

    def build_token(session)
      Librum::Iam::Authentication::Jwt::Generate.new.call(session)
    end

    def find_credential(password:, username:)
      Librum::Iam::Authentication::Passwords::Find
        .new(repository:)
        .call(password:, username:)
    end

    def process(password:, username:, **)
      credential = step { find_credential(password:, username:) }
      session    = Librum::Iam::Session.new(credential: credential)

      step { build_token(session) }
    end
  end
end
