# frozen_string_literal: true

module Librum::Iam
  # An identifier used to authenticate a user.
  class Credential < Librum::Iam::ApplicationRecord
    extend Librum::Core::Models::DataProperties

    ### Associations
    belongs_to :user,
      class_name: 'Librum::Iam::User'

    ### Validations
    validates :active,
      inclusion: {
        in:      [true, false],
        message: I18n.t('errors.messages.blank')
      }
    validates :expires_at,
      presence: true
    validates :type, presence: true

    # @return [true, false] true if the expires_at date is in the past, otherwise
    #   false.
    def expired?
      expires_at < Time.current
    end
  end
end

# == Schema Information
#
# Table name: librum_iam_credentials
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  data       :jsonb            not null
#  expires_at :datetime         not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_librum_iam_credentials_on_user_id           (user_id)
#  index_librum_iam_credentials_on_user_id_and_type  (user_id,type)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => librum_iam_users.id)
#
