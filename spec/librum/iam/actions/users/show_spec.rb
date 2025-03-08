# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Actions::Users::Show do
  subject(:action) { described_class.new }

  let(:repository) { Cuprum::Rails::Records::Repository.new }

  describe '#call' do
    def call_action
      action.call(
        repository: repository,
        request:    request
      )
    end

    it 'should define the method' do
      expect(action).to be_callable.with(0).arguments.and_keywords(:request)
    end

    describe 'with an unauthenticated request' do
      let(:request) { Cuprum::Rails::Request.new }
      let(:expected_error) do
        Librum::Core::Errors::AuthenticationFailed.new
      end

      it 'should return a failing result' do
        expect(call_action)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with an authenticated request' do
      let(:credential) { FactoryBot.create(:generic_credential, :with_user) }
      let(:session)    { Librum::Iam::Session.new(credential: credential) }
      let(:request)    { Librum::Iam::Request.new(session: session) }
      let(:expected_value) do
        { 'user' => request.current_user }
      end

      it 'should return a passing request' do
        expect(call_action)
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
