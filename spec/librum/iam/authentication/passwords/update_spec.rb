# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Passwords::Update do
  subject(:command) { described_class.new(repository: repository, user: user) }

  let(:repository) do
    Cuprum::Rails::Records::Repository.new.tap do |repository|
      repository.find_or_create(entity_class: Librum::Iam::Credential)
      repository.find_or_create(entity_class: Librum::Iam::User)
    end
  end
  let(:user) { FactoryBot.build(:user) }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :user)
    end
  end

  describe '#call' do
    let(:old_password) { 'tronlives' }
    let(:new_password) { 'ifightfortheusers' }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:new_password, :old_password)
    end

    describe 'when the user does not have a password credential' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MissingPassword
          .new(user_id: user.id)
      end

      it 'should return a failing result' do
        expect(
          command.call(new_password: new_password, old_password: old_password)
        )
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
        user.save!

        FactoryBot.create(:password_credential, :inactive, user: user)
      end

      it 'should return a failing result' do
        expect(
          command.call(new_password: new_password, old_password: old_password)
        )
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'when the old password does not match the credential' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::InvalidPassword.new
      end

      before(:example) do
        user.save!

        FactoryBot.create(:password_credential, :active, user: user)
      end

      it 'should return a failing result' do
        expect(
          command.call(new_password: new_password, old_password: old_password)
        )
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
          password:   old_password
        )
      end

      before(:example) do
        user.save!

        password_credential.save!

        allow(Time).to receive(:current).and_return(current_time)
      end

      it 'should return a passing result' do
        expect(
          command.call(new_password: new_password, old_password: old_password)
        )
          .to be_a_passing_result
          .with_value(an_instance_of(Librum::Iam::PasswordCredential))
      end

      it 'should deactivate the old credential' do # rubocop:disable RSpec/ExampleLength
        expect do
          command.call(new_password: new_password, old_password: old_password)
        end
          .to(
            change { password_credential.reload.active? }
            .to be false
          )
      end

      it 'should create a password credential' do
        expect do
          command.call(new_password: new_password, old_password: old_password)
        end
          .to change(Librum::Iam::PasswordCredential, :count)
          .by(1)
      end

      it 'should set the password credential attributes', :aggregate_failures do
        command.call(new_password: new_password, old_password: old_password)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(credential.active?).to be true
        expect(credential.user).to be == user
        expect(credential.expires_at.to_i).to be 1.year.from_now.to_i
      end

      it 'should set the encrypted password' do
        command.call(new_password: new_password, old_password: old_password)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last
        password   = BCrypt::Password.new(credential.encrypted_password)

        expect(password).to be == new_password
      end

      it 'should return the created password credential' do
        result =
          command.call(new_password: new_password, old_password: old_password)
        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(result.value).to be == credential
      end
    end

    describe 'when the password credential is valid' do
      let(:current_time) { Time.current }
      let(:password_credential) do
        FactoryBot.build(
          :password_credential,
          :active,
          user:     user,
          password: old_password
        )
      end

      before(:example) do
        user.save!

        password_credential.save!

        allow(Time).to receive(:current).and_return(current_time)
      end

      it 'should return a passing result' do
        expect(
          command.call(new_password: new_password, old_password: old_password)
        )
          .to be_a_passing_result
          .with_value(an_instance_of(Librum::Iam::PasswordCredential))
      end

      it 'should deactivate the old credential' do # rubocop:disable RSpec/ExampleLength
        expect do
          command.call(new_password: new_password, old_password: old_password)
        end
          .to(
            change { password_credential.reload.active? }
            .to be false
          )
      end

      it 'should create a password credential' do
        expect do
          command.call(new_password: new_password, old_password: old_password)
        end
          .to change(Librum::Iam::PasswordCredential, :count)
          .by(1)
      end

      it 'should set the password credential attributes', :aggregate_failures do
        command.call(new_password: new_password, old_password: old_password)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(credential.active?).to be true
        expect(credential.user).to be == user
        expect(credential.expires_at.to_i).to be 1.year.from_now.to_i
      end

      it 'should set the encrypted password' do
        command.call(new_password: new_password, old_password: old_password)

        credential = Librum::Iam::PasswordCredential.order(:created_at).last
        password   = BCrypt::Password.new(credential.encrypted_password)

        expect(password).to be == new_password
      end

      it 'should return the created password credential' do
        result =
          command.call(new_password: new_password, old_password: old_password)
        credential = Librum::Iam::PasswordCredential.order(:created_at).last

        expect(result.value).to be == credential
      end
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end

  describe '#user' do
    include_examples 'should define reader', :user, -> { user }
  end
end
