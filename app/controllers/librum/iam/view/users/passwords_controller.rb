# frozen_string_literal: true

require 'librum/core/actions/view/render_page'
require 'librum/core/resources/view_resource'
require 'librum/core/responders/html/resource_responder'

require 'librum/iam/actions/users/passwords/update'
require 'librum/iam/view/components/users/passwords/form'

module Librum::Iam::View::Users
  # Controller for managing the current user's password.
  class PasswordsController < Librum::Core::ViewController
    def self.resource
      base_path = Librum::Iam::Engine.config.authentication_user_password_path

      Librum::Core::Resources::ViewResource.new(
        base_path:      base_path,
        form_component: Librum::Iam::View::Components::Users::Passwords::Form,
        resource_class: Librum::Iam::PasswordCredential,
        resource_name:  'password',
        singular:       true
      )
    end

    responder :html, Librum::Core::Responders::Html::ResourceResponder

    action :edit,   Librum::Core::Actions::View::RenderPage

    action :update, Librum::Iam::Actions::Users::Passwords::Update
  end
end
