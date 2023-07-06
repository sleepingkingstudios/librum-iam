# frozen_string_literal: true

require 'librum/iam/authentication/errors/invalid_login'
require 'librum/iam/view/components/sessions/form'
require 'librum/iam/view/pages'

module Librum::Iam::View::Pages
  # Renders the login page for the application.
  class LoginPage < Librum::Core::View::Components::Page; end
end
