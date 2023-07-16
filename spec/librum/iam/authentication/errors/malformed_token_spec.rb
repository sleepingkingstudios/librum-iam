# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Errors::MalformedToken do
  subject(:error) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '::TYPE' do
    include_examples 'should define constant',
      :TYPE,
      'librum.iam.authentication.errors.malformed_token'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message)
        .and_any_keywords
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {},
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) { 'malformed authentication token' }

    include_examples 'should define reader', :message, -> { be == expected }

    context 'when initialized with message: value' do
      let(:message)             { 'something went wrong' }
      let(:constructor_options) { super().merge(message: message) }

      it { expect(error.message).to be == message }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
