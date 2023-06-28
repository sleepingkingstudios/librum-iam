# frozen_string_literal: true

require 'cuprum/rails/action'

require 'librum/iam/actions/sessions'

module Librum::Iam::Actions::Sessions
  # Action for destroying an authentication session.
  class Destroy < Cuprum::Rails::Action
    private

    def native_session
      request.native_session
    end

    def process(request:)
      super

      native_session.delete('auth_token')

      {}
    end
  end
end
