# frozen_string_literal: true

module Librum::Iam::Users
  # Controller for managing the current user's password.
  class PasswordsController < Librum::Core::ViewController
    def self.resource
      base_path = Librum::Iam::Engine.config.authentication_user_password_path

      @resource ||=
        Librum::Core::Resource.new(
          base_path:    base_path,
          components:   Librum::Iam::Users::Passwords::View::Components,
          entity_class: Librum::Iam::PasswordCredential,
          name:         'password',
          singular:     true
        )
    end

    responder :html, Librum::Core::Responders::Html::ResourceResponder

    action(:edit, Cuprum::Rails::Action.subclass { |*| success(nil) })

    action :update, Librum::Iam::Actions::Users::Passwords::Update
  end
end
