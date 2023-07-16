# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Strategies::RequestToken do
  subject(:strategy) { described_class.new(repository: repository) }

  shared_context 'with a request with an empty Authorization header' do
    let(:headers) { super().merge('Authorization' => '') }
  end

  shared_context 'with a request with a non-bearer Authorization header' do
    let(:headers) { super().merge('Authorization' => 'Basic 12345') }
  end

  shared_context 'with a request with an empty bearer Authorization header' do
    let(:headers) { super().merge('Authorization' => 'Bearer') }
  end

  shared_context 'with a request with a bearer Authorization header' do
    let(:token)   { 'token' }
    let(:headers) { super().merge('Authorization' => "Bearer #{token}") }
  end

  shared_context 'with a request with a token parameter' do
    let(:token)  { 'token' }
    let(:params) { super().merge('token' => token) }
  end

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap do |repo|
        repo.find_or_create(record_class: Librum::Iam::Credential)
      end
  end
  let(:headers) { {} }
  let(:params)  { {} }
  let(:request) do
    instance_double(
      Cuprum::Rails::Request,
      authorization: headers['Authorization'],
      headers:       headers,
      params:        params
    )
  end

  describe '.matches?' do
    it { expect(described_class).to respond_to(:matches?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:matches?).as(:match?) }

    it { expect(described_class.matches?(request)).to be false }

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'with a request with an empty Authorization header' do
      it { expect(described_class.matches?(request)).to be false }
    end

    wrap_context 'with a request with a non-bearer Authorization header' do
      it { expect(described_class.matches?(request)).to be false }
    end

    wrap_context 'with a request with an empty bearer Authorization header' do
      it { expect(described_class.matches?(request)).to be true }
    end

    wrap_context 'with a request with a bearer Authorization header' do
      it { expect(described_class.matches?(request)).to be true }
    end

    wrap_context 'with a request with a token parameter' do
      it { expect(described_class.matches?(request)).to be true }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
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
          expect(strategy.call(request))
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
          expect(strategy.call(request))
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
          expect(strategy.call(request))
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
          expect(strategy.call(request))
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
          expect(strategy.call(request))
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
          expect(strategy.call(request))
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
            expect(strategy.call(request))
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
            expect(strategy.call(request))
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        context 'when the credential is valid' do
          let(:new_session) { strategy.call(request).value }

          before(:example) { credential.save! }

          it 'should return a passing result' do
            expect(strategy.call(request))
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
      expect(strategy.call(request))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'with a request with an empty Authorization header' do
      it 'should return a failing result' do
        expect(strategy.call(request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_context 'with a request with a non-bearer Authorization header' do
      it 'should return a failing result' do
        expect(strategy.call(request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_context 'with a request with an empty bearer Authorization header' do
      it 'should return a failing result' do
        expect(strategy.call(request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_context 'with a request with a bearer Authorization header' do
      include_examples 'should decode the token'
    end

    wrap_context 'with a request with a token parameter' do
      include_examples 'should decode the token'
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
