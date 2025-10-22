# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/rspec/deferred/controller_examples'
require 'cuprum/rails/rspec/deferred/responder_examples'
require 'cuprum/rails/rspec/deferred/responses/html_response_examples'

RSpec.describe Librum::Iam::View::SessionsController do
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  describe '::HtmlResponder' do
    include Cuprum::Rails::RSpec::Deferred::ResponderExamples
    include Cuprum::Rails::RSpec::Deferred::Responses::HtmlResponseExamples

    subject(:responder) do
      described_class::HtmlResponder.new(**constructor_options)
    end

    let(:action_name) { 'process' }
    let(:constructor_options) do
      {
        action_name:   action_name,
        controller:    controller,
        member_action: false,
        request:       Cuprum::Rails::Request.new
      }
    end

    describe '#call' do
      let(:response) { responder.call(result) }

      it { expect(responder).to respond_to(:call).with(1).argument }

      describe 'with action: create' do
        let(:action_name) { 'create' }

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }

          include_deferred 'should redirect back'
        end

        describe 'with a failing result with an InvalidLogin error' do
          let(:error)  { Librum::Iam::Authentication::Errors::InvalidLogin.new }
          let(:result) { Cuprum::Result.new(error: error) }
          let(:flash) do
            {
              danger: {
                icon:    'user-xmark',
                message: 'Invalid username or password.'
              }
            }
          end

          include_deferred 'should redirect back',
            flash: -> { flash }
        end
      end

      describe 'with action: destroy' do
        let(:action_name) { 'destroy' }

        describe 'with a passing result' do
          let(:result) { Cuprum::Result.new(status: :success) }
          let(:flash) do
            {
              warning: {
                icon:    'user-xmark',
                message: 'You have successfully logged out.'
              }
            }
          end

          include_deferred 'should redirect to', '/', flash: -> { flash }
        end
      end
    end
  end

  describe '.resource' do
    subject(:resource) { described_class.resource }

    it { expect(resource).to be_a Librum::Core::Resources::BaseResource }

    it { expect(resource.name).to be == 'sessions' }

    it { expect(resource.singular?).to be true }

    it { expect(resource.skip_authentication.to_a).to be == %w[create destroy] }
  end

  describe '.responders' do
    include_deferred 'should respond to format',
      :html,
      using: described_class::HtmlResponder
  end

  include_deferred 'should define middleware',
    Librum::Iam::Authentication::Middleware::DestroySession,
    actions: { only: :destroy }

  include_deferred 'should define middleware',
    Librum::Iam::Authentication::Middleware::RegenerateSession,
    actions: { only: :create }

  include_deferred 'should define action',
    :create,
    Librum::Iam::Authentication::Sessions::Actions::Create,
    member: false

  include_deferred 'should define action',
    :destroy,
    Librum::Iam::Authentication::Sessions::Actions::Destroy,
    member: false
end
