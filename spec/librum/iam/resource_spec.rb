# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/resource'

RSpec.describe Librum::Iam::Resource do
  subject(:resource) { described_class.new(**constructor_options) }

  let(:described_class)     { Spec::AuthenticatedResource }
  let(:constructor_options) { { resource_name: 'rockets' } }

  example_class 'Spec::AuthenticatedResource', Cuprum::Rails::Resource \
  do |klass|
    klass.include Librum::Iam::Resource # rubocop:disable RSpec/DescribedClass
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:skip_authentication)
        .and_any_keywords
    end
  end

  describe '#skip_authentication' do
    include_examples 'should define reader', :skip_authentication, false

    context 'when initialized with skip_authentication: false' do
      let(:constructor_options) do
        super().merge(skip_authentication: false)
      end

      it { expect(resource.skip_authentication).to be false }
    end

    context 'when initialized with skip_authentication: true' do
      let(:constructor_options) do
        super().merge(skip_authentication: true)
      end

      it { expect(resource.skip_authentication).to be true }
    end

    context 'when initialized with skip_authentication: a String' do
      let(:constructor_options) do
        super().merge(skip_authentication: 'launch')
      end

      it { expect(resource.skip_authentication).to be_a Set }

      it { expect(resource.skip_authentication.to_a).to be == %w[launch] }
    end

    context 'when initialized with skip_authentication: a Symbol' do
      let(:constructor_options) do
        super().merge(skip_authentication: :launch)
      end

      it { expect(resource.skip_authentication).to be_a Set }

      it { expect(resource.skip_authentication.to_a).to be == %w[launch] }
    end

    context 'when initialized with skip_authentication: an Array of Strings' do
      let(:constructor_options) do
        super().merge(skip_authentication: %w[launch orbit])
      end

      it { expect(resource.skip_authentication).to be_a Set }

      it { expect(resource.skip_authentication.to_a).to be == %w[launch orbit] }
    end

    context 'when initialized with skip_authentication: an Array of Symbols' do
      let(:constructor_options) do
        super().merge(skip_authentication: %i[launch orbit])
      end

      it { expect(resource.skip_authentication).to be_a Set }

      it { expect(resource.skip_authentication.to_a).to be == %w[launch orbit] }
    end
  end

  describe '#skip_authentication_for' do
    it 'should define the method' do
      expect(resource)
        .to respond_to(:skip_authentication_for?)
        .with(1).argument
    end

    describe 'with action name: a String' do
      it { expect(resource.skip_authentication_for?('launch')).to be false }
    end

    describe 'with action name: a Symbol' do
      it { expect(resource.skip_authentication_for?(:launch)).to be false }
    end

    context 'when initialized with skip_authentication: false' do
      let(:constructor_options) do
        super().merge(skip_authentication: false)
      end

      describe 'with action name: a String' do
        it { expect(resource.skip_authentication_for?('launch')).to be false }
      end

      describe 'with action name: a Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be false }
      end
    end

    context 'when initialized with skip_authentication: true' do
      let(:constructor_options) do
        super().merge(skip_authentication: true)
      end

      describe 'with action name: a String' do
        it { expect(resource.skip_authentication_for?('launch')).to be true }
      end

      describe 'with action name: a Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be true }
      end
    end

    context 'when initialized with skip_authentication: a String' do
      let(:constructor_options) do
        super().merge(skip_authentication: 'launch')
      end

      describe 'with action name: a non-matching String' do
        it { expect(resource.skip_authentication_for?('recover')).to be false }
      end

      describe 'with action name: a non-matching Symbol' do
        it { expect(resource.skip_authentication_for?(:recover)).to be false }
      end

      describe 'with action name: a matching String' do
        it { expect(resource.skip_authentication_for?('launch')).to be true }
      end

      describe 'with action name: a matching Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be true }
      end
    end

    context 'when initialized with skip_authentication: a Symbol' do
      let(:constructor_options) do
        super().merge(skip_authentication: :launch)
      end

      describe 'with action name: a non-matching String' do
        it { expect(resource.skip_authentication_for?('recover')).to be false }
      end

      describe 'with action name: a non-matching Symbol' do
        it { expect(resource.skip_authentication_for?(:recover)).to be false }
      end

      describe 'with action name: a matching String' do
        it { expect(resource.skip_authentication_for?('launch')).to be true }
      end

      describe 'with action name: a matching Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be true }
      end
    end

    context 'when initialized with skip_authentication: an Array of Strings' do
      let(:constructor_options) do
        super().merge(skip_authentication: %w[launch orbit])
      end

      describe 'with action name: a non-matching String' do
        it { expect(resource.skip_authentication_for?('recover')).to be false }
      end

      describe 'with action name: a non-matching Symbol' do
        it { expect(resource.skip_authentication_for?(:recover)).to be false }
      end

      describe 'with action name: a matching String' do
        it { expect(resource.skip_authentication_for?('launch')).to be true }
      end

      describe 'with action name: a matching Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be true }
      end
    end

    context 'when initialized with skip_authentication: an Array of Symbols' do
      let(:constructor_options) do
        super().merge(skip_authentication: %i[launch orbit])
      end

      describe 'with action name: a non-matching String' do
        it { expect(resource.skip_authentication_for?('recover')).to be false }
      end

      describe 'with action name: a non-matching Symbol' do
        it { expect(resource.skip_authentication_for?(:recover)).to be false }
      end

      describe 'with action name: a matching String' do
        it { expect(resource.skip_authentication_for?('launch')).to be true }
      end

      describe 'with action name: a matching Symbol' do
        it { expect(resource.skip_authentication_for?(:launch)).to be true }
      end
    end
  end
end
