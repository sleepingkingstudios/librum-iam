# frozen_string_literal: true

require 'librum/core/resources/view_resource'
require 'librum/core/responders/html/resource_responder'

require 'librum/iam/actions/users/show'
require 'librum/iam/view/components/users/block'

module Librum::Iam::View
  # Controller for managing the current user.
  class UsersController < Librum::Core::ViewController
    def self.resource
      @resource ||=
        Librum::Core::Resources::ViewResource.new(
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
