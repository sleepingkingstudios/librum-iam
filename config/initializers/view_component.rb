# frozen_string_literal: true

require 'view_component'

ViewComponent::Base.config[:test_controller]     =
  'Librum::Core::ApplicationController'
ViewComponent::Base.config[:view_component_path] = 'app/components'
