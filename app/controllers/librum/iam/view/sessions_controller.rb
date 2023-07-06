# frozen_string_literal: true

require 'librum/core/resources/base_resource'
require 'librum/core/responders/html/view_responder'
require 'librum/core/view/layouts/page'
require 'librum/iam/actions/sessions/create'
require 'librum/iam/authentication/errors/invalid_login'

module Librum::Iam::View
  # Controller for managing authentication sessions.
  class SessionsController < Librum::Core::ViewController
    # Responder class for authentication responses.
    class Responder < Librum::Core::Responders::Html::ViewResponder
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
      Librum::Core::Resources::BaseResource.new(
        resource_name:       'sessions',
        skip_authentication: %i[create destroy],
        singular:            true
      )
    end

    responder :html, Librum::Iam::View::SessionsController::Responder

    action :create,  Librum::Iam::Actions::Sessions::Create

    action :destroy, Cuprum::Rails::Action
  end
end
