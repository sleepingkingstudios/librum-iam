# frozen_string_literal: true

require 'bcrypt'

module Librum::Iam::RSpec::Factories
  # Shared RSpec factories for Credential models.
  module CredentialFactories
    extend Librum::Core::RSpec::Factories::SharedFactories

    factory :credential,
      class:   'Librum::Iam::Credential',
      aliases: %i[librum_iam_credential] \
    do
      id { SecureRandom.uuid }

      data       { {} }
      active     { false }
      expires_at { 1.year.from_now }

      trait :active do
        active { true }
      end

      trait :expired do
        expires_at { 1.hour.ago }
      end

      trait :inactive do
        active { false }
      end

      trait :with_user do
        user { association :user }
      end
    end

    factory :generic_credential,
      class:   'Librum::Iam::GenericCredential',
      parent:  :credential,
      aliases: %i[librum_iam_generic_credential]

    factory :password_credential,
      class:   'Librum::Iam::PasswordCredential',
      parent:  :credential,
      aliases: %i[librum_iam_password_credential] \
    do
      transient do
        password { 'password' }
      end

      encrypted_password { BCrypt::Password.create(password).to_s }
    end
  end
end
