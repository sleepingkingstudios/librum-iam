# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/authentication/passwords/generate'

RSpec.describe Librum::Iam::Authentication::Passwords::Generate do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:password) { 'password' }

    it { expect(command).to be_callable.with(1).argument }

    it 'should return a passing result' do
      expect(command.call(password))
        .to be_a_passing_result
        .with_value(an_instance_of(String))
    end

    it 'should hash the password' do
      hashed = command.call(password).value

      expect(BCrypt::Password.new(hashed)).to be == password
    end
  end
end
