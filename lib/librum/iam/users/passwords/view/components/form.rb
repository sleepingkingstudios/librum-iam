# frozen_string_literal: true

module Librum::Iam::Users::Passwords::View::Components
  # Renders a form for updating the current user's password.
  class Form < Librum::Components::Views::Resources::Elements::Form
    private

    def action
      Librum::Iam::Engine.config.authentication_user_password_path
    end

    def buttons_options
      {
        cancel_url: Librum::Iam::Engine.config.authentication_user_path,
        class_name: 'mt-5',
        color:      'primary',
        text:       'Update Password'
      }
    end

    def build_form
      components::Form.new(action:, http_method: 'PATCH', result:) do |form|
        form.input :old_password, icon_left: 'key', type: :password

        form.input :new_password, icon_left: 'key', type: :password

        form.input :confirm_password, icon_left: 'key', type: :password

        form.buttons(**buttons_options)
      end
    end

    def render_form = render(build_form)
  end
end
