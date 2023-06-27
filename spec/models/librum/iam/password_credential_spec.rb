# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/password_credential'
require 'librum/iam/rspec/contracts/credential_contracts'

RSpec.describe Librum::Iam::PasswordCredential, type: :model do
  include Librum::Iam::RSpec::Contracts::CredentialContracts

  subject(:credential) { described_class.new(attributes) }

  let(:attributes) do
    {
      active:     true,
      data:       {
        'encrypted_password' => Base64.encode64('password')
      },
      expires_at: 1.year.from_now
    }
  end

  include_contract 'should be a credential',
    type: 'Librum::Iam::PasswordCredential'

  include_contract 'should define data property', :encrypted_password

  describe '#valid?' do
    include_contract 'should validate the presence of',
      :encrypted_password,
      attributes: lambda { |hsh|
        password = hsh.delete(:encrypted_password)

        hsh.merge(data: hsh[:data].merge('encrypted_password' => password))
      },
      type:       :string

    context 'when the password is not active' do
      let(:user)       { FactoryBot.build(:user) }
      let(:attributes) { super().merge(user: user, active: false) }

      before(:example) { user.save! }

      context 'when another password exists for the user' do
        let(:other) { FactoryBot.build(:password_credential, user: user) }

        before(:example) { other.save! }

        it { expect(credential.valid?).to be true }
      end
    end

    context 'when the password is active' do
      let(:user)       { FactoryBot.build(:user) }
      let(:attributes) { super().merge(user: user, active: true) }

      before(:example) { user.save! }

      context 'when an inactive password exists for the user' do
        let(:other) do
          FactoryBot.build(:password_credential, :inactive, user: user)
        end

        before(:example) { other.save! }

        it { expect(credential.valid?).to be true }
      end

      context 'when an active password exists for the user' do
        let(:other) do
          FactoryBot.build(:password_credential, :active, user: user)
        end

        before(:example) { other.save! }

        it 'should validate the uniqueness' do
          expect(credential)
            .to have_errors
            .on(:user_id)
            .with_message('has already been taken')
        end
      end
    end

    describe 'with a user' do
      let(:user)       { FactoryBot.build(:user) }
      let(:attributes) { super().merge(user: user) }

      before(:example) { user.save! }

      it { expect(credential.valid?).to be true }
    end
  end
end
