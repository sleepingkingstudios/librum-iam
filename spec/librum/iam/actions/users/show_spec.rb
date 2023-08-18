# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Actions::Users::Show do
  subject(:action) do
    described_class.new(repository: repository, resource: resource)
  end

  let(:repository) { Cuprum::Rails::Repository.new }
  let(:resource) do
    Cuprum::Rails::Resource.new(resource_class: Librum::Iam::User)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :resource)
    end
  end

  describe '#call' do
    it 'should define the method' do
      expect(action).to be_callable.with(0).arguments.and_keywords(:request)
    end

    describe 'with an unauthenticated request' do
      let(:request) { Cuprum::Rails::Request.new }
      let(:expected_error) do
        Librum::Core::Errors::AuthenticationFailed.new
      end

      it 'should return a failing result' do
        expect(action.call(request: request))
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
        expect(action.call(request: request))
          .to be_a_passing_result
          .with_value(expected_value)
      end
    end
  end
end
