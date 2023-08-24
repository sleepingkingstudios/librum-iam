# frozen_string_literal: true

module Librum::Iam::View::Users
  # Controller for managing the current user's password.
  class PasswordsController < Librum::Core::ViewController
    def self.resource
      base_path = Librum::Iam::Engine.config.authentication_user_password_path

      @resource ||=
        Librum::Core::Resources::ViewResource.new(
          base_path:      base_path,
          form_component: Librum::Iam::View::Components::Users::Passwords::Form,
          resource_class: Librum::Iam::PasswordCredential,
          resource_name:  'password',
          singular:       true
        )
    end

    responder :html, Librum::Core::Responders::Html::ResourceResponder

    action :edit,   Cuprum::Rails::Action

    action :update, Librum::Iam::Actions::Users::Passwords::Update
  end
end
