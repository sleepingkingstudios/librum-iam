# frozen_string_literal: true

require 'cuprum/rails/records/repository'

module Librum::Iam
  # Repository with collections for Librum::Iam records.
  class Repository < Cuprum::Rails::Records::Repository
    def initialize(**)
      super

      create(
        entity_class: Librum::Iam::Credential,
        name:         'librum/iam/credentials'
      )
      create(
        entity_class: Librum::Iam::User,
        name:         'librum/iam/users'
      )
    end
  end
end
