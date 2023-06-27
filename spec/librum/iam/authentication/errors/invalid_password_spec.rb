# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/authentication/errors/invalid_password'

RSpec.describe Librum::Iam::Authentication::Errors::InvalidPassword do
  subject(:error) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '::TYPE' do
    include_examples 'should define constant',
      :TYPE,
      'librum.iam.authentication.errors.invalid_password'
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {},
        'message' => error.message,
        'type'    => error.type
      }
    end

    it { expect(error.as_json).to be == expected }
  end

  describe '#message' do
    let(:expected) { 'password does not match encrypted value' }

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
