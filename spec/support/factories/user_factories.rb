# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'Librum::Iam::User' do
    id { SecureRandom.uuid }

    transient do
      sequence(:user_index) { |index| index }
    end

    email    { "user.#{user_index}@example.com" }
    username { "User #{user_index}" }
    slug     { "user-#{user_index}" }
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
