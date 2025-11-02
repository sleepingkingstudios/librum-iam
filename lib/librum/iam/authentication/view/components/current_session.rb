# frozen_string_literal: true

module Librum::Iam::Authentication::View::Components
  # Component displaying the current user, if any.
  class CurrentSession < Librum::Components::Base
    option :destroy_path,
      default:  -> { Librum::Iam::Engine.config.authentication_session_path },
      validate: String

    option :session, validate: Librum::Iam::Session

    option :user_path,
      default:  -> { Librum::Iam::Engine.config.authentication_user_path },
      validate: String

    # @return [true, false] true if the session is present, otherwise false.
    def render?
      session.present?
    end

    private

    def build_destroy_form
      return if destroy_path.blank?

      components::Resources::DestroyButton.new(
        confirm: false,
        icon:    'user-xmark',
        link:    true,
        text:    'Log Out',
        url:     destroy_path
      )
    end

    def label_text
      return "You are currently logged in as #{user_name}." if user_path.blank?

      safe_buffer do |buffer|
        buffer << 'You are currently logged in as '
        buffer << strip_buffer(render_user_link)
        buffer << '.'
      end
    end

    def level_options
      {
        left_items:  [components::Label.new(text: label_text)],
        right_items: [build_destroy_form].compact
      }
    end

    def render_user_link
      render(components::Link.new(text: user_name, url: user_path))
    end

    def user_name
      session.authenticated_user.username
    end
  end
end
