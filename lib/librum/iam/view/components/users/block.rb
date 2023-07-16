# frozen_string_literal: true

module Librum::Iam::View::Components::Users
  # Renders the current user.
  class Block < ViewComponent::Base
    FIELDS = [
      { key: 'username' }.freeze,
      { key: 'slug' }.freeze,
      { key: 'email' }.freeze,
      {
        key:   'role',
        value: ->(user) { user.role.capitalize }
      }.freeze
    ].freeze
    private_constant :FIELDS

    # @param data [Librum::Iam::User] the user to display.
    def initialize(data:, **)
      super()

      @data = data
    end

    # @return [Librum::Iam::User] the user to display.
    attr_reader :data

    # @return [Array<DataField::FieldDefinition>] the configuration objects for
    #   rendering the user.
    def fields
      FIELDS
    end
  end
end
