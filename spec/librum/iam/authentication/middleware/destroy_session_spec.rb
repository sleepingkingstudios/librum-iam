# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Middleware::DestroySession do
  subject(:middleware) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:next_result)  { Cuprum::Result.new }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
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
      expect(middleware).to be_callable.with(1).argument.and_keywords(:request)
    end

    it 'should call the next command' do
      middleware.call(next_command, request: request)

      expect(next_command).to have_received(:call).with(request: request)
    end

    it 'should clear the authentication session' do
      middleware.call(next_command, request: request)

      expect(native_session).to have_received(:delete).with('auth_token')
    end
  end
end
