# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/repository'
require 'cuprum/rails/rspec/deferred/actions_examples'

RSpec.describe Librum::Iam::Authentication::Sessions::Actions::Create do
  include Cuprum::Rails::RSpec::Deferred::ActionsExamples

  subject(:action) { described_class.new }

  let(:repository) { Cuprum::Rails::Records::Repository.new }
  let(:resource)   { Cuprum::Rails::Resource.new(name: 'sessions') }

  include_deferred 'should implement the action methods',
    command_class: Librum::Iam::Authentication::Sessions::Commands::Create

  describe '#call' do
    include_deferred 'with parameters for an action'

    include_deferred 'should validate the parameters',
      using_contract:   described_class::CONTRACT,
      validation_error: lambda {
        Librum::Iam::Authentication::Errors::InvalidLogin
          .new(errors: configured_errors)
      }

    describe 'with valid parameters' do
      let(:params) do
        { 'username' => 'Alan Bradley', 'password' => 'tronlives' }
      end
      let(:expected_result) do
        Cuprum::Result.new(value: '12345')
      end
      let(:expected_value) do
        { 'token' => expected_result.value }
      end

      include_deferred 'should delegate to the command'
    end
  end
end
