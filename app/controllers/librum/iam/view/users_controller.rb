# frozen_string_literal: true

module Librum::Iam::View
  # Controller for managing the current user.
  class UsersController < Librum::Core::ViewController
    def self.resource
      @resource ||=
        Librum::Core::Resources::ViewResource.new(
          actions:         %w[show],
          block_component: Librum::Iam::View::Components::Users::Block,
          resource_class:  Librum::Iam::User,
          resource_name:   'user',
          singular:        true
        )
    end

    responder :html, Librum::Core::Responders::Html::ResourceResponder

    action :show, Librum::Iam::Actions::Users::Show
  end
end
