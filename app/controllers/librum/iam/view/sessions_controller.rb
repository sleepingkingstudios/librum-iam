# frozen_string_literal: true

module Librum::Iam::View
  # Controller for managing authentication sessions.
  class SessionsController < Librum::Core::ViewController
    # Responder class for authentication responses.
    class HtmlResponder < Librum::Core::Responders::Html::ViewResponder
      action :create do
        match :success do
          redirect_back
        end

        match :failure,
          error: Librum::Iam::Authentication::Errors::InvalidLogin \
        do
          alert = {
            icon:    'user-xmark',
            message: 'Invalid username or password.'
          }

          redirect_back(flash: { danger: alert })
        end
      end

      action :destroy do
        match :success do
          alert = {
            icon:    'user-xmark',
            message: 'You have successfully logged out.'
          }

          redirect_to(
            '/',
            flash: { warning: alert }
          )
        end
      end
    end

    def self.resource
      @resource ||=
        Librum::Core::Resources::BaseResource.new(
          name:                'sessions',
          skip_authentication: %i[create destroy],
          singular:            true
        )
    end

    responder :html, Librum::Iam::View::SessionsController::HtmlResponder

    action :create,  Librum::Iam::Authentication::Sessions::Actions::Create

    action :destroy, Librum::Iam::Authentication::Sessions::Actions::Destroy
  end
end
