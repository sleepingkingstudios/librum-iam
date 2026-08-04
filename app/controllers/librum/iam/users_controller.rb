# frozen_string_literal: true

module Librum::Iam
  # Controller for managing the current user.
  class UsersController < Librum::Core::ViewController
    def self.resource
      @resource ||=
        Librum::Core::Resource.new(
          actions:      %w[show],
          components:   Librum::Iam::Users::View::Components,
          entity_class: Librum::Iam::User,
          name:         'user',
          singular:     true
        )
    end

    responder :html, Librum::Core::Responders::Html::ResourceResponder

    action :show, Librum::Iam::Actions::Users::Show
  end
end
