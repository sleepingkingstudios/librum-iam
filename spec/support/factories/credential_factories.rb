# frozen_string_literal: true

require 'bcrypt'

FactoryBot.define do
  factory :credential, class: 'Librum::Iam::Credential' do
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
      user { create(:user) } # rubocop:disable FactoryBot/FactoryAssociationWithStrategy
    end
  end

  factory :generic_credential,
    class:  'Librum::Iam::GenericCredential',
    parent: :credential
end
