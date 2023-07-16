# frozen_string_literal: true

require 'rails_helper'

require 'stannum'

RSpec.describe Librum::Iam::Authentication::Errors::InvalidLogin do
  subject(:error) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '::TYPE' do
    include_examples 'should define constant',
      :TYPE,
      'librum.iam.authentication.errors.invalid_login'
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

    context 'when initialized with errors: value' do
      let(:errors) do
        Stannum::Errors
          .new
          .add('spec.example_error')
      end
      let(:constructor_options) { super().merge(errors: errors) }
      let(:expected) do
        super().merge('data' => { 'errors' => errors.as_json })
      end

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, nil

    context 'when initialized with errors: value' do
      let(:errors) do
        Stannum::Errors
          .new
          .add('spec.example_error')
      end
      let(:constructor_options) { super().merge(errors: errors) }

      it { expect(error.errors).to be errors }
    end
  end

  describe '#message' do
    let(:expected) { 'invalid username or password' }

    include_examples 'should define reader', :message, -> { be == expected }
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
