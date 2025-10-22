# frozen_string_literal: true

require 'jwt'

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Sessions::Commands::Create do
  subject(:command) { described_class.new(repository:) }

  let(:repository) do
    Cuprum::Rails::Records::Repository.new.tap do |repository|
      repository.create(entity_class: Librum::Iam::Credential)
      repository.create(entity_class: Librum::Iam::User)
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
    let(:username) { 'Alan Bradley' }
    let(:password) { '12345' }
    let(:expected_error) do
      Librum::Iam::Authentication::Errors::InvalidLogin.new
    end

    define_method :call_command do
      command.call(password:, username:)
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:password, :username)
        .and_any_keywords
    end

    context 'when the user does not exist' do
      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the user exists' do
      let(:user) { FactoryBot.build(:user, username:) }

      before(:example) { user.save! }

      it 'should return a failing result' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when an expired password credential exists' do
        let(:password) { 'tronlives' }
        let(:credential) do
          FactoryBot.build(
            :password_credential,
            active:     true,
            expires_at: 1.day.ago,
            password:   password,
            user:       user
          )
        end

        before(:example) { credential.save! }

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when a non-matching password credential exists' do
        let(:credential) do
          FactoryBot.build(
            :password_credential,
            active: true,
            user:   user
          )
        end

        before(:example) { credential.save! }

        it 'should return a failing result' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when a valid password credential exists' do
        let(:password) { 'tronlives' }
        let(:credential) do
          FactoryBot.build(
            :password_credential,
            active:   true,
            password:,
            user:
          )
        end
        let(:decoded_token) do
          JWT.decode(
            encoded_token,
            Rails.application.secret_key_base,
            true,
            { algorithm: 'HS512' }
          )
        end
        let(:payload)      { decoded_token.first }
        let(:current_time) { Time.current }

        def encoded_token
          result = call_command

          result.value
        end

        before(:example) do
          credential.save!

          allow(Time).to receive(:current).and_return(current_time)
        end

        it 'should return a passing result' do
          expect(call_command)
            .to be_a_passing_result
            .with_value(an_instance_of(String))
        end

        it { expect(payload['exp']).to be == (current_time + 1.day).to_i }

        it { expect(payload['sub']).to be == credential.id }
      end
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
