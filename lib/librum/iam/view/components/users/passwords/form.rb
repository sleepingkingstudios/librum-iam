# frozen_string_literal: true

require 'librum/iam/view/components/users/passwords'

module Librum::Iam::View::Components::Users::Passwords
  # Renders a form for updating the current user's password.
  class Form < ViewComponent::Base
    # @param errors [Stannum::Errors] the errors to render.
    def initialize(errors:, **)
      super()

      @errors = errors
    end

    # @return [Stannum::Errors] the errors to render.
    attr_reader :errors
  end
end
