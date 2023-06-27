# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/constant_map'

module Librum::Iam
  # A user or identity authorized to access the system.
  class User < Librum::Iam::ApplicationRecord
    Roles = SleepingKingStudios::Tools::Toolbox::ConstantMap.new(
      GUEST:      'guest',
      USER:       'user',
      ADMIN:      'admin',
      SUPERADMIN: 'superadmin'
    ).freeze

    ### Validations
    validates :email,
      presence:   true,
      format:     {
        with:    /.@./,
        message: I18n.t('errors.messages.email_address'),
        unless:  -> { email.blank? }
      },
      uniqueness: true
    validates :role,
      presence:  true,
      inclusion: {
        in:     Roles.values,
        unless: -> { role.blank? }
      }
    validates :slug,
      format:     {
        message: I18n.t('errors.messages.kebab_case'),
        with:    /\A[a-z0-9]+(-[a-z0-9]+)*\z/
      },
      presence:   true,
      uniqueness: true
    validates :username,
      presence:   true,
      uniqueness: true

    def admin?
      role == Roles::ADMIN
    end

    def guest?
      role == Roles::GUEST
    end

    def superadmin?
      role == Roles::SUPERADMIN
    end

    def user?
      role == Roles::USER
    end
  end
end

# == Schema Information
#
# Table name: librum_iam_users
#
#  id         :uuid             not null, primary key
#  email      :string           default(""), not null
#  role       :string           default(""), not null
#  slug       :string           default(""), not null
#  username   :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_librum_iam_users_on_email     (email) UNIQUE
#  index_librum_iam_users_on_slug      (slug) UNIQUE
#  index_librum_iam_users_on_username  (username) UNIQUE
#
