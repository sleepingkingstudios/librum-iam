# frozen_string_literal: true

module Librum::Iam::RSpec
  # Namespace for shared FactoryBot factory definitions.
  module Factories
    FACTORY_DEFINITIONS = %w[
      Credential
      User
    ].freeze
    private_constant :FACTORY_DEFINITIONS

    def self.define_factories
      FACTORY_DEFINITIONS.each do |name|
        definition = const_get("#{name}Factories")

        definition.define_factories
      end
    end
  end
end
