# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Errors::ExpiredCredential do
  subject(:error) { described_class.new(**constructor_options) }

  let(:credential_id)       { SecureRandom.uuid }
  let(:constructor_options) { { credential_id: credential_id } }

  describe '::TYPE' do
    include_examples 'should define constant',
      :TYPE,
      'librum.iam.authentication.errors.expired_credential'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:credential_id, :message)
        .and_any_keywords
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'credential_id' => credential_id
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#credential_id' do
    include_examples 'should define reader',
      :credential_id,
      -> { be == credential_id }
  end

  describe '#message' do
    let(:expected) { "credential not found with id: #{credential_id.inspect}" }

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
