# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/repository'

RSpec.describe Librum::Iam::Authentication::Passwords::Find do
  subject(:command) { described_class.new(repository: repository) }

  let(:repository) do
    Cuprum::Rails::Repository.new.tap do |repository|
      repository.find_or_create(entity_class: Librum::Iam::Credential)
      repository.find_or_create(entity_class: Librum::Iam::User)
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
    let(:username) { 'Ed Dillinger' }
    let(:password) { 'mastercontrolprogram' }
    let(:expected_error) do
      Librum::Iam::Authentication::Errors::InvalidLogin.new
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:password, :username)
    end

    it 'should return a failing result' do
      expect(command.call(username: username, password: password))
        .to be_a_failing_result
        .with_error(expected_error)
    end

    describe 'with password: nil' do
      it 'should return a failing result' do
        expect(command.call(username: username, password: nil))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with password: an empty String' do
      it 'should return a failing result' do
        expect(command.call(username: username, password: ''))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with username: nil' do
      it 'should return a failing result' do
        expect(command.call(username: nil, password: password))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with username: an empty String' do
      it 'should return a failing result' do
        expect(command.call(username: '', password: password))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    context 'when the user exists' do
      let(:user)     { FactoryBot.build(:user) }
      let(:username) { user.username }

      before(:example) { user.save! }

      it 'should return a failing result' do
        expect(command.call(username: username, password: password))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      context 'when an inactive password credential exists' do
        let(:credential) do
          FactoryBot.build(
            :password_credential,
            active:   false,
            password: password,
            user:     user
          )
        end

        before(:example) { credential.save! }

        it 'should return a failing result' do
          expect(command.call(username: username, password: password))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when an expired password credential exists' do
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
          expect(command.call(username: username, password: password))
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
          expect(command.call(username: username, password: password))
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      context 'when a matching password credential exists' do
        let(:password) { 'tronlives' }
        let(:credential) do
          FactoryBot.build(
            :password_credential,
            active:   true,
            password: password,
            user:     user
          )
        end

        before(:example) { credential.save! }

        it 'should return a passing result' do
          expect(command.call(username: username, password: password))
            .to be_a_passing_result
            .with_value(credential)
        end
      end
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
