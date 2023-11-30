# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Middleware::AuthenticateRequest do
  subject(:middleware) { described_class.new }

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource)   { Spec::Resource.new(name: 'rockets') }

  example_class 'Spec::Resource', Cuprum::Rails::Resource do |klass|
    klass.include Librum::Iam::Resource
  end

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:result)       { Cuprum::Result.new(value: { 'ok' => true }) }
    let(:next_command) { instance_double(Cuprum::Command, call: result) }
    let(:credential)   { FactoryBot.build(:generic_credential) }
    let(:session)      { Librum::Iam::Session.new(credential: credential) }
    let(:mock_result)  { Cuprum::Result.new(value: session) }
    let(:mock_strategy) do
      instance_double(
        Librum::Iam::Authentication::Strategies::RequestToken,
        call: mock_result
      )
    end
    let(:request) do
      instance_double(
        Cuprum::Rails::Request,
        action_name: 'launch',
        context:     Object.new.freeze,
        properties:  { action_name: 'launch' }
      )
    end
    let(:expected_request) do
      be_a(Librum::Iam::Request).and(
        have_attributes(
          action_name: 'launch',
          context:     request.context,
          session:     session
        )
      )
    end
    let(:options) { { custom_option: 'custom value' } }

    def call_action
      middleware.call(
        next_command,
        repository: repository,
        request:    request,
        resource:   resource,
        **options
      )
    end

    before(:example) do
      allow(Librum::Iam::Authentication::Strategies::RequestToken)
        .to receive(:new)
        .and_return(mock_strategy)
    end

    it 'should define the method' do
      expect(middleware)
        .to be_callable
        .with(1).arguments
        .and_keywords(:repository, :request, :resource)
        .and_any_keywords
    end

    it 'should return a passing result' do
      expect(call_action)
        .to be_a_passing_result
        .with_value(result.value)
    end

    it 'should authenticate the request' do
      call_action

      expect(mock_strategy).to have_received(:call).with(request)
    end

    it 'should call the action' do # rubocop:disable RSpec/ExampleLength
      call_action

      expect(next_command)
        .to have_received(:call)
        .with(
          repository: repository,
          request:    expected_request,
          resource:   resource,
          **options
        )
    end

    context 'when the authentication fails' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:mock_error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:mock_result) { Cuprum::Result.new(error: mock_error) }

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(mock_error)
      end

      it 'should authenticate the request' do
        call_action

        expect(mock_strategy).to have_received(:call).with(request)
      end

      it 'should not call the action' do
        call_action

        expect(next_command).not_to have_received(:call)
      end
    end

    context 'when the resource does not authenticate the action' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:resource) do
        Spec::Resource.new(
          name:                'rockets',
          skip_authentication: true
        )
      end

      it 'should return a passing result' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(result.value)
      end

      it 'should not authenticate the request' do
        call_action

        expect(mock_strategy).not_to have_received(:call)
      end

      it 'should call the action' do # rubocop:disable RSpec/ExampleLength
        call_action

        expect(next_command)
          .to have_received(:call)
          .with(
            repository: repository,
            request:    request,
            resource:   resource,
            **options
          )
      end
    end
  end
end
