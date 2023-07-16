# frozen_string_literal: true

require 'librum/iam/version'
require 'librum/iam/engine'
require 'librum/core/railtie' if defined?(Rails::Railtie)

module Librum
  # Librum engine defining authentication and authorization.
  module Iam; end
end
