# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Strategies::SessionToken do
  subject(:strategy) { described_class.new(repository: repository) }

  shared_context 'with a session with an auth_token' do
    let(:token) { 'token' }

    before(:example) do
      allow(native_session).to receive(:[]) do |key|
        key == 'auth_token' ? token : nil
      end

      allow(native_session).to receive(:key?) do |key|
        key == 'auth_token'
      end
    end
  end

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap do |repo|
        repo.find_or_create(entity_class: Librum::Iam::Credential)
      end
  end
  let(:native_session) do
    instance_double(
      ActionDispatch::Request::Session,
      '[]': nil,
      key?: false
    )
  end

  describe '.matches?' do
    it { expect(described_class).to respond_to(:matches?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:matches?).as(:match?) }

    it { expect(described_class.matches?(native_session)).to be false }

    context 'with a session with an empty auth_token' do
      include_context 'with a session with an auth_token'

      let(:token) { '' }

      it { expect(described_class.matches?(native_session)).to be true }
    end

    wrap_context 'with a session with an auth_token' do
      it { expect(described_class.matches?(native_session)).to be true }
    end
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository)
    end
  end

  describe '#call' do
    shared_examples 'should decode the token' do
      describe 'with token: an empty String' do
        let(:token) { '' }

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: a non-token String' do
        let(:token) { 'letmein' }
        let(:expected_error) do
          Librum::Iam::Authentication::Errors::MalformedToken.new
        end

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: an unsigned token' do
        let(:credential) { FactoryBot.create(:generic_credential, :with_user) }
        let(:expires_at) { 1.day.from_now }
        let(:token) do
          JWT.encode({ exp: expires_at.to_i, sub: credential.id }, nil, 'none')
        end
        let(:expected_error) do
          Librum::Iam::Authentication::Errors::InvalidToken.new
        end

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: a token without an expiration timestamp' do
        let(:credential) { FactoryBot.create(:generic_credential, :with_user) }
        let(:token) do
          secret  = Rails.application.secret_key_base
          payload = { sub: credential.id }

          JWT.encode(payload, secret, 'HS512')
        end
        let(:expected_error) do
          Librum::Iam::Authentication::Errors::InvalidToken.new
        end

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: a token without a subject' do
        let(:token) do
          secret  = Rails.application.secret_key_base
          payload = { exp: 1.day.from_now.to_i }

          JWT.encode(payload, secret, 'HS512')
        end
        let(:expected_error) do
          Librum::Iam::Authentication::Errors::InvalidToken.new
        end

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: an expired token' do
        let(:credential) { FactoryBot.create(:generic_credential, :with_user) }
        let(:expires_at) { 1.day.ago }
        let(:session) do
          Librum::Iam::Session.new(
            credential: credential,
            expires_at: expires_at
          )
        end
        let(:token) do
          Librum::Iam::Authentication::Jwt::Generate.new.call(session).value
        end
        let(:expected_error) do
          Librum::Iam::Authentication::Errors::ExpiredToken.new
        end

        it 'should return a failing result' do
          expect(strategy.call(native_session))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with token: a valid token' do
        let(:credential) { FactoryBot.build(:generic_credential, :with_user) }
        let(:expires_at) { 1.day.from_now }
        let(:session) do
          Librum::Iam::Session.new(
            credential: credential,
            expires_at: expires_at
          )
        end
        let(:token) do
          Librum::Iam::Authentication::Jwt::Generate.new.call(session).value
        end

        context 'when the credential does not exist' do
          let(:expected_error) do
            Librum::Iam::Authentication::Errors::MissingCredential
              .new(credential_id: credential.id)
          end

          it 'should return a failing result' do
            expect(strategy.call(native_session))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the credential is expired' do
          let(:credential) do
            FactoryBot.build(
              :generic_credential,
              :with_user,
              expires_at: 1.day.ago
            )
          end
          let(:token) do
            secret  = Rails.application.secret_key_base
            payload = {
              exp: 1.day.from_now.to_i,
              sub: credential.id
            }

            JWT.encode(payload, secret, 'HS512')
          end
          let(:expected_error) do
            Librum::Iam::Authentication::Errors::ExpiredCredential
              .new(credential_id: credential.id)
          end

          before(:example) { credential.save! }

          it 'should return a failing result' do
            expect(strategy.call(native_session))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the credential is valid' do
          let(:new_session) { strategy.call(native_session).value }

          before(:example) { credential.save! }

          it 'should return a passing result' do
            expect(strategy.call(native_session))
              .to be_a_passing_result
              .with_value(an_instance_of(Librum::Iam::Session))
          end

          it { expect(new_session.credential).to be == credential }

          it 'should set the expiration timestamp' do
            expect(new_session.expires_at).to be_a ActiveSupport::TimeWithZone
          end

          it { expect(new_session.expires_at.to_i).to be expires_at.to_i }
        end
      end
    end

    let(:expected_error) do
      Librum::Iam::Authentication::Errors::MissingToken.new
    end

    it { expect(strategy).to be_callable.with(1).argument }

    it 'should return a failing result' do
      expect(strategy.call(native_session))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    wrap_context 'with a session with an auth_token' do
      include_examples 'should decode the token'
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
