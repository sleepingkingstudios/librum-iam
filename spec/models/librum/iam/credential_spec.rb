# frozen_string_literal: true

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
require 'rails_helper'

RSpec.describe Librum::Iam::Credential, type: :model do
  include Librum::Iam::RSpec::Contracts::CredentialContracts

  subject(:credential) { described_class.new(attributes) }

  let(:attributes) do
    {
      active:     true,
      data:       {
        'key' => 'value'
      },
      expires_at: 1.year.from_now
    }
  end

  include_contract 'should be a credential', type: nil

  describe '#valid?' do
    include_contract 'should validate the presence of', :type, type: String
  end
end
