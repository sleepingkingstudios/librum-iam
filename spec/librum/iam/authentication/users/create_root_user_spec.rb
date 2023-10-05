# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Users::CreateRootUser do
  subject(:command) { described_class.new(repository: repository) }

  let(:repository) { Cuprum::Rails::Repository.new }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository)
    end
  end

  describe '#call' do
    let(:email)    { 'alan.bradley@example.com' }
    let(:username) { 'Alan Bradley' }
    let(:password) { 'tronlives' }
    let(:params)   { { email: email, username: username, password: password } }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:email, :password, :username)
    end

    describe 'with an invalid password' do
      let(:password) { '' }
      let(:expected_error) do
        Cuprum::Error.new(message: "Password can't be blank")
      end

      it 'should return a failing result' do
        expect(command.call(**params))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not create a user' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::User, :count)
      end

      it 'should not create a credential' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::Credential, :count)
      end
    end

    describe 'with an invalid email' do
      let(:email) { '' }
      let(:expected_error) do
        be_a(Cuprum::Collections::Errors::FailedValidation)
          .and have_attributes(message: 'Librum::Iam::User failed validation')
      end

      it 'should return a failing result' do
        expect(command.call(**params))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not create a user' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::User, :count)
      end

      it 'should not create a credential' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::Credential, :count)
      end
    end

    describe 'with an invalid username' do
      let(:username) { '' }
      let(:expected_error) do
        be_a(Cuprum::Collections::Errors::FailedValidation)
          .and have_attributes(message: 'Librum::Iam::User failed validation')
      end

      it 'should return a failing result' do
        expect(command.call(**params))
          .to be_a_failing_result
          .with_error(expected_error)
      end

      it 'should not create a user' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::User, :count)
      end

      it 'should not create a credential' do
        expect { command.call(**params) }
          .not_to change(Librum::Iam::Credential, :count)
      end
    end

    describe 'with a valid username and password' do
      let(:expected_user) do
        an_instance_of(Librum::Iam::User).and(
          have_attributes(
            email:    email,
            role:     Librum::Iam::User::Roles::SUPERADMIN,
            username: username
          )
        )
      end
      let(:current_time) { Time.current }

      before(:example) do
        allow(Time).to receive(:current).and_return(current_time)
      end

      it 'should return a passing result' do
        expect(command.call(**params))
          .to be_a_passing_result
          .with_value(expected_user)
      end

      it 'should create a user', :aggregate_failures do
        expect { command.call(**params) }
          .to change(Librum::Iam::User, :count)
          .by(1)

        expect(Librum::Iam::User.last).to match expected_user
      end

      it 'should create a password credential', :aggregate_failures do # rubocop:disable RSpec/ExampleLength
        expect { command.call(**params) }
          .to change(Librum::Iam::Credential, :count)
          .by(1)

        credential = Librum::Iam::Credential.last
        expect(credential).to be_a Librum::Iam::PasswordCredential
        expect(credential.expires_at.to_i).to be == (current_time + 1.year).to_i
      end

      it 'should set the password' do # rubocop:disable RSpec/ExampleLength
        command.call(**params)

        credential = Librum::Iam::Credential.last
        validator  =
          Librum::Iam::Authentication::Passwords::Match
          .new(credential.encrypted_password)

        expect(validator.call(password)).to be_a_passing_result
      end

      context 'when a user already exists' do
        let(:expected_error) do
          Cuprum::Error.new(message: 'a Librum::Iam::User already exists')
        end

        before(:example) { FactoryBot.create(:user) }

        it 'should return a failing result' do
          expect(command.call(**params))
            .to be_a_failing_result
            .with_error(expected_error)
        end

        it 'should not create a user' do
          expect { command.call(**params) }
            .not_to change(Librum::Iam::User, :count)
        end

        it 'should not create a credential' do
          expect { command.call(**params) }
            .not_to change(Librum::Iam::Credential, :count)
        end
      end
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
