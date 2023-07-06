# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/actions/users/passwords/update'
require 'librum/iam/request'
require 'librum/iam/session'

RSpec.describe Librum::Iam::Actions::Users::Passwords::Update do
  subject(:action) do
    described_class.new(repository: repository, resource: resource)
  end

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(
      collection:     repository.find_or_create(
        record_class: Librum::Iam::Credential
      ),
      resource_class: Librum::Iam::Credential
    )
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :resource)
    end
  end

  describe '#call' do
    let(:user)       { FactoryBot.create(:user) }
    let(:credential) { FactoryBot.create(:generic_credential, user: user) }
    let(:session)    { Librum::Iam::Session.new(credential: credential) }
    let(:params) do
      {
        'old_password'     => 'tronlives',
        'new_password'     => 'ifightfortheusers',
        'confirm_password' => 'ifightfortheusers'
      }
    end
    let(:request) do
      Librum::Iam::Request.new(
        params:  params,
        session: session
      )
    end

    it 'should define the method' do
      expect(action).to be_callable.with(0).arguments.and_keywords(:request)
    end

    describe 'with an unauthenticated request' do
      let(:request) { Cuprum::Rails::Request.new }
      let(:expected_error) do
        Librum::Core::Errors::AuthenticationFailed.new
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with empty params' do
      let(:params) { {} }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['confirm_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )
        errors['old_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )
        errors['new_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with confirm_password: blank' do
      let(:params) { super().merge('confirm_password' => '') }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['confirm_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with old_password: blank' do
      let(:params) { super().merge('old_password' => '') }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['old_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with new_password: blank' do
      let(:params) { super().merge('new_password' => '') }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['new_password'].add(
          Stannum::Constraints::Presence::TYPE,
          message: "can't be blank"
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with new_password equal to old_password' do
      let(:params) do
        hsh = super()

        hsh.merge(
          'new_password'     => hsh['old_password'],
          'confirm_password' => hsh['old_password']
        )
      end
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['new_password'].add(
          Stannum::Constraints::Equality::NEGATED_TYPE,
          message: "can't match old password"
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with confirm_password not equal to new_password' do
      let(:params) { super().merge('confirm_password' => 'greetingsprograms') }
      let(:expected_errors) do
        errors = Stannum::Errors.new

        errors['confirm_password'].add(
          Stannum::Constraints::Equality::TYPE,
          message:  'does not match',
          expected: '[FILTERED]',
          actual:   '[FILTERED]'
        )

        errors
      end
      let(:expected_error) do
        Cuprum::Rails::Errors::InvalidParameters.new(errors: expected_errors)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'when the user does not have a password credential' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MissingPassword
          .new(user_id: user.id)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'when the user does not have an active password credential' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MissingPassword
          .new(user_id: user.id)
      end

      before(:example) do
        FactoryBot.create(:password_credential, :inactive, user: user)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'when the old password does not match the credential' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::InvalidPassword.new
      end

      before(:example) do
        FactoryBot.create(:password_credential, :active, user: user)
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'when the password credential is expired' do
      let(:current_time) { Time.current }
      let(:password_credential) do
        FactoryBot.build(
          :password_credential,
          :active,
          user:       user,
          expires_at: 1.day.ago,
          password:   params['old_password']
        )
      end

      def decode_token(encoded_token)
        JWT.decode(
          encoded_token,
          Rails.application.secret_key_base,
          true,
          { algorithm: 'HS512' }
        )
      end

      before(:example) do
        password_credential.save!

        allow(Time).to receive(:current).and_return(current_time)
      end

      it 'should return a passing result' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(deep_match({ 'token' => an_instance_of(String) }))
      end

      it 'should generate a session token', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        result        = action.call(request: request)
        encoded_token = result.value['token']
        decoded_token = decode_token(encoded_token)
        payload       = decoded_token.first
        credential    = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(payload['exp']).to be == (current_time + 1.day).to_i
        expect(payload['sub']).to be == credential.id
      end

      it 'should deactivate the old credential' do
        expect { action.call(request: request) }
          .to(
            change { password_credential.reload.active? }
            .to be false
          )
      end

      it 'should create a password credential' do
        expect { action.call(request: request) }
          .to change(Librum::Iam::PasswordCredential, :count)
          .by(1)
      end

      it 'should set the password credential attributes', :aggregate_failures do
        action.call(request: request)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(credential.active?).to be true
        expect(credential.user).to be == user
        expect(credential.expires_at.to_i).to be 1.year.from_now.to_i
      end

      it 'should set the encrypted password' do
        action.call(request: request)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last
        password   = BCrypt::Password.new(credential.encrypted_password)

        expect(password).to be == params['new_password']
      end
    end

    describe 'when the password credential is valid' do
      let(:current_time) { Time.current }
      let(:password_credential) do
        FactoryBot.build(
          :password_credential,
          :active,
          user:     user,
          password: params['old_password']
        )
      end

      def decode_token(encoded_token)
        JWT.decode(
          encoded_token,
          Rails.application.secret_key_base,
          true,
          { algorithm: 'HS512' }
        )
      end

      before(:example) do
        password_credential.save!

        allow(Time).to receive(:current).and_return(current_time)
      end

      it 'should return a passing result' do
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(deep_match({ 'token' => an_instance_of(String) }))
      end

      it 'should generate a session token', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        result        = action.call(request: request)
        encoded_token = result.value['token']
        decoded_token = decode_token(encoded_token)
        payload       = decoded_token.first
        credential    = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(payload['exp']).to be == (current_time + 1.day).to_i
        expect(payload['sub']).to be == credential.id
      end

      it 'should deactivate the old credential' do
        expect { action.call(request: request) }
          .to(
            change { password_credential.reload.active? }
            .to be false
          )
      end

      it 'should create a password credential' do
        expect { action.call(request: request) }
          .to change(Librum::Iam::PasswordCredential, :count)
          .by(1)
      end

      it 'should set the password credential attributes', :aggregate_failures do
        action.call(request: request)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(credential.active?).to be true
        expect(credential.user).to be == user
        expect(credential.expires_at.to_i).to be 1.year.from_now.to_i
      end

      it 'should set the encrypted password' do
        action.call(request: request)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last
        password   = BCrypt::Password.new(credential.encrypted_password)

        expect(password).to be == params['new_password']
      end
    end
  end
end
