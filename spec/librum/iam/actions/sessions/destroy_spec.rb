# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/repository'
require 'cuprum/rails/resource'

require 'librum/iam/actions/sessions/destroy'

RSpec.describe Librum::Iam::Actions::Sessions::Destroy do
  subject(:action) do
    described_class.new(
      repository: repository,
      resource:   resource
    )
  end

  let(:repository) do
    Cuprum::Rails::Repository.new.tap do |repository|
      repository.find_or_create(record_class: Librum::Iam::Credential)
      repository.find_or_create(record_class: Librum::Iam::User)
    end
  end
  let(:resource) { Cuprum::Rails::Resource.new(resource_name: 'sessions') }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository, :resource)
    end
  end

  describe '#call' do
    let(:native_session) do
      instance_double(ActionDispatch::Request::Session, delete: nil)
    end
    let(:request) do
      instance_double(
        Cuprum::Rails::Request,
        native_session: native_session
      )
    end

    it 'should define the method' do
      expect(action)
        .to be_callable
        .with(0).arguments
        .and_keywords(:request)
    end

    it 'should return a passing result' do
      expect(action.call(request: request))
        .to be_a_passing_result
        .with_value({})
    end

    it 'should clear the session' do
      action.call(request: request)

      expect(native_session).to have_received(:delete).with('auth_token')
    end
  end
end
