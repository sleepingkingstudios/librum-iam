# frozen_string_literal: true

module Librum::Iam
  # Example implementation of the abstract Credential class.
  class GenericCredential < Librum::Iam::Credential
    data_property :details, predicate: true
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
