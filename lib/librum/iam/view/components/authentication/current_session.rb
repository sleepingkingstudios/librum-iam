# frozen_string_literal: true

require 'librum/core/view/components/link'

require 'librum/iam/view/components/authentication'

module Librum::Iam::View::Components::Authentication
  # Renders the current authentication session.
  class CurrentSession < ViewComponent::Base
    extend Forwardable

    # @param session [Librum::Iam::Session] the current session.
    def initialize(session:)
      super()

      @session = session
    end

    def_delegators :@session,
      :current_user

    # @return [Librum::Iam::Session] the current session.
    attr_reader :session
  end
end
