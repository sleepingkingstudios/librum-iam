# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Passwords::Match do
  subject(:command) { described_class.new(encrypted_password) }

  let(:password)           { 'password' }
  let(:encrypted_password) { BCrypt::Password.create(password).to_s }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#call' do
    it { expect(command).to be_callable.with(1).argument }

    describe 'with a non-matching value' do
      let(:expected_error) do
        Librum::Iam::Authentication::Errors::InvalidPassword.new
      end

      it 'should return a failing result' do
        expect(command.call('12345'))
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a matching value' do
      it 'should return a passing result' do
        expect(command.call(password))
          .to be_a_passing_result
          .with_value(nil)
      end
    end
  end

  describe '#encrypted_password' do
    include_examples 'should define reader',
      :encrypted_password,
      -> { be == encrypted_password }
  end
end
