# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Jwt::Generate do
  subject(:command) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:credential) { FactoryBot.build(:generic_credential, :with_user) }
    let(:expires_at) { 1.hour.from_now }
    let(:session) do
      Librum::Iam::Session.new(
        credential: credential,
        expires_at: expires_at
      )
    end
    let(:decoded_token) do
      JWT.decode(
        command.call(session).value,
        Rails.application.secret_key_base,
        true,
        { algorithm: 'HS512' }
      )
    end
    let(:payload) { decoded_token.first }

    before(:example) { credential.save! }

    it { expect(command).to be_callable.with(1).argument }

    it 'should return a passing result' do
      expect(command.call(session))
        .to be_a_passing_result
        .with_value(an_instance_of(String))
    end

    it { expect(payload['exp']).to be == expires_at.to_i }

    it { expect(payload['sub']).to be == credential.id }
  end
end
