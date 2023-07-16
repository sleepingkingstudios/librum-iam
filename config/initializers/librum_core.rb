# frozen_string_literal: true

require 'librum/iam/resource'

Librum::Core::Engine.instance_exec do
  config.after_initialize do
    # Add authentication config to all controller resources.
    Librum::Core::Resources::BaseResource.include(Librum::Iam::Resource)
  end
end
