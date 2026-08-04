# frozen_string_literal: true

module Librum::Iam::Responders::Html
  # Helper for responding to authentication failures.
  module AuthenticatedResponder
    extend ActiveSupport::Concern

    included do
      match :failure,
        error: Librum::Core::Errors::AuthenticationError \
      do |result|
        page =
          Librum::Iam::Authentication::Sessions::View::Pages::LoginPage
          .new(result:)

        render_component(
          page,
          layout: 'login',
          status: :unauthorized
        )
      end
    end
  end
end
