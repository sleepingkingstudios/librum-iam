# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'Librum::Iam::User' do
    id { SecureRandom.uuid }

    transient do
      sequence(:user_index) { |index| index }
    end

    username { "User #{user_index}" }
    email    { "#{username.underscore.tr(' ', '.')}@example.com" }
    slug     { username.tr(' ', '_').underscore.tr('_', '-') }
    role     { Librum::Iam::User::Roles::USER }

    trait :admin do
      role { Librum::Iam::User::Roles::ADMIN }
    end

    trait :guest do
      role { Librum::Iam::User::Roles::GUEST }
    end

    trait :superadmin do
      role { Librum::Iam::User::Roles::SUPERADMIN }
    end
  end
end
