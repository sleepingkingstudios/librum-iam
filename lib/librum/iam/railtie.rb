# frozen_string_literal: true

require 'librum/iam'

module Librum::Iam
  # Handles Rails configuration and initializers.
  class Railtie < Rails::Railtie
    root_path = Pathname.new(__dir__).join('../../..')
    overrides = root_path.join('lib/ext')

    config.before_configuration do
      Rails.autoloaders.each { |autoloader| autoloader.ignore(overrides) }

      config.authentication_session_path = nil
      config.authentication_user_path    = nil
    end

    config.to_prepare do
      Dir.glob("#{overrides}/**/*.rb").each do |override|
        load override
      end
    end
  end
end
