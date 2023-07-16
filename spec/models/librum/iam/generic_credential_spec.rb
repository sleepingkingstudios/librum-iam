# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::GenericCredential, type: :model do
  include Librum::Iam::RSpec::Contracts::CredentialContracts

  subject(:credential) { described_class.new(attributes) }

  let(:attributes) do
    {
      active:     true,
      data:       {
        'details' => 'Zzzzz...',
        'key'     => 'value'
      },
      expires_at: 1.year.from_now
    }
  end

  include_contract 'should be a credential',
    type: 'Librum::Iam::GenericCredential'

  include_contract 'should define data property', :details, predicate: true

  describe '#valid?' do
    describe 'with a user' do
      let(:user)       { FactoryBot.build(:user) }
      let(:attributes) { super().merge(user: user) }

      before(:example) { user.save! }

      it { expect(credential.valid?).to be true }
    end
  end
end
