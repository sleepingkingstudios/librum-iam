# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Errors::MissingPassword do
  subject(:error) { described_class.new(**constructor_options) }

  let(:user_id)             { SecureRandom.uuid }
  let(:constructor_options) { { user_id: user_id } }

  describe '::TYPE' do
    include_examples 'should define constant',
      :TYPE,
      'librum.iam.authentication.errors.missing_password'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message, :user_id)
        .and_any_keywords
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'user_id' => user_id
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }
  end

  describe '#message' do
    let(:expected) do
      "password credential not found for user with id: #{user_id.inspect}"
    end

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end

  describe '#user_id' do
    include_examples 'should define reader', :user_id, -> { user_id }
  end
end
