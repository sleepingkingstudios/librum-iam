# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Jwt::Parse do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    it { expect(command).to be_callable.with(1).argument }

    describe 'with nil' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MalformedToken.new
      end

      it 'should return a failing result' do
        expect(command.call(nil))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an Object' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MalformedToken.new
      end

      it 'should return a failing result' do
        expect(command.call(Object.new.freeze))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an empty String' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MalformedToken.new
      end

      it 'should return a failing result' do
        expect(command.call(''))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a non-token String' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::MalformedToken.new
      end

      it 'should return a failing result' do
        expect(command.call('letmein'))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an unsigned token' do
      let(:credential) { FactoryBot.build(:generic_credential, :with_user) }
      let(:expires_at) { 1.day.from_now }
      let(:token) do
        JWT.encode({ exp: expires_at.to_i, sub: credential.id }, nil, 'none')
      end
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::InvalidToken.new
      end

      it 'should return a failing result' do
        expect(command.call(token))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an expired token' do
      let(:credential) { FactoryBot.build(:generic_credential, :with_user) }
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
        expect(command.call(token))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a valid token' do
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
      let(:expected_value) do
        {
          'credential_id' => credential.id,
          'expires_at'    => expires_at.to_i
        }
      end

      it 'should return a passing result' do
        expect(command.call(token))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
