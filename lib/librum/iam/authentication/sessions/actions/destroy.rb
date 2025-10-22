# frozen_string_literal: true

module Librum::Iam::Authentication::Sessions::Actions
  # Action for destroying an authentication session.
  class Destroy < Cuprum::Rails::Action
    private

    def build_response(token)
      { 'token' => token }
    end

    def default_command_class
      Librum::Iam::Authentication::Sessions::Commands::Destroy
    end
  end
end
