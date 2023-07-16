# frozen_string_literal: true

require 'cuprum/rails/action'

module Librum::Iam::Actions::Users
  # Action to show the current authenticated user.
  class Show < Cuprum::Rails::Action
    private

    def process(request:)
      super

      session = step { require_session }

      { 'user' => session.current_user }
    end

    def require_session
      return request.session if request.respond_to?(:session) && request.session

      error = Librum::Core::Errors::AuthenticationFailed.new

      failure(error)
    end
  end
end
