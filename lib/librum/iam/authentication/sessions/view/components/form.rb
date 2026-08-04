# frozen_string_literal: true

module Librum::Iam::Authentication::Sessions::View::Components
  # Renders a form for creating a new authentication session.
  class Form < Librum::Components::Base
    private

    def action
      Librum::Iam::Engine.config.authentication_session_path
    end

    def build_form
      components::Form.new(action:, result:) do |form|
        form.input :username, icon_left: 'user'

        form.input :password, icon_left: 'key', type: :password

        form.buttons(class_name: 'mt-5', color: 'primary', text: 'Log In')
      end
    end

    def render_form = render(build_form)

    def result
      # Forms require a result object, but we don't pass one to the session form
      # to prevent data leaks.
      Cuprum::Rails::Result.new
    end
  end
end
