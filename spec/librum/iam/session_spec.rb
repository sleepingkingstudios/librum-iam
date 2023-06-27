# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/session'

RSpec.describe Librum::Iam::Session do
  subject(:session) { described_class.new(**constructor_options) }

  let(:credential) do
    FactoryBot.build(:generic_credential, :with_user)
  end
  let(:constructor_options) do
    { credential: credential }
  end

  describe '.new' do
    let(:expected_keywords) do
      %i[
        authenticated_user
        credential
        expires_at
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end
  end

  describe '#authenticated_user' do
    include_examples 'should define reader',
      :authenticated_user,
      -> { credential.user }

    context 'when initialized with an authenticated user' do
      let(:authenticated_user) { FactoryBot.build(:user) }
      let(:constructor_options) do
        super().merge(authenticated_user: authenticated_user)
      end

      it { expect(session.authenticated_user).to be authenticated_user }
    end
  end

  describe '#authorized_user' do
    include_examples 'should define reader',
      :authorized_user,
      -> { credential.user }

    it 'should alias the method' do
      expect(session)
        .to have_aliased_method(:authorized_user)
        .as(:current_user)
    end
  end

  describe '#credential' do
    include_examples 'should define reader', :credential, -> { credential }
  end

  describe '#expired?' do
    include_examples 'should define predicate', :expired?, false

    context 'when the credential is expired' do
      let(:credential) do
        super().tap { |obj| obj.expires_at = 1.hour.ago }
      end

      it { expect(session.expired?).to be true }
    end

    context 'when initialized with expires_at: a time in the past' do
      let(:expires_at) { 1.hour.ago }
      let(:constructor_options) do
        super().merge(expires_at: expires_at)
      end

      it { expect(session.expires_at).to be == expires_at }
    end
  end

  describe '#expires_at' do
    let(:current_time) { Time.current }
    let(:expected)     { current_time + (24 * 60 * 60) }

    before(:example) do
      allow(Time).to receive(:current).and_return(current_time)
    end

    include_examples 'should define reader', :expires_at, -> { be == expected }

    context 'when the credential expires sooner' do
      let(:credential) do
        super().tap { |obj| obj.expires_at = 1.hour.from_now }
      end
      let(:expected) { current_time + 3_600 }

      it { expect(session.expires_at).to be == expected }
    end

    context 'when initialized with expires_at: value' do
      let(:expires_at) { 1.week.from_now }
      let(:constructor_options) do
        super().merge(expires_at: expires_at)
      end

      it { expect(session.expires_at).to be == expires_at }

      context 'when the credential expires sooner' do
        let(:credential) do
          super().tap { |obj| obj.expires_at = 1.hour.from_now }
        end
        let(:expected) { current_time + 3_600 }

        it { expect(session.expires_at).to be == expected }
      end
    end
  end
end
