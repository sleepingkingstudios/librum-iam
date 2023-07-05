# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/authentication/middleware/regenerate_session'

RSpec.describe Librum::Iam::Authentication::Middleware::RegenerateSession do
  subject(:middleware) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:next_result)  { Cuprum::Result.new }
    let(:next_command) { instance_double(Cuprum::Command, call: next_result) }
    let(:native_session) do
      instance_double(ActionDispatch::Request::Session, '[]=': nil)
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

    it 'should return the result' do
      expect(middleware.call(next_command, request: request))
        .to be == next_result
    end

    it 'should not update the native session' do
      middleware.call(next_command, request: request)

      expect(native_session).not_to have_received(:[]=)
    end

    context 'when the next command returns a failing result' do
      let(:next_error)  { Cuprum::Error.new(message: 'Something went wrong') }
      let(:next_result) { Cuprum::Result.new(error: next_error) }

      it 'should return the result' do
        expect(middleware.call(next_command, request: request))
          .to be == next_result
      end

      it 'should not update the native session' do
        middleware.call(next_command, request: request)

        expect(native_session).not_to have_received(:[]=)
      end
    end

    context 'when the next command returns a result with a Hash value' do
      let(:next_result) { Cuprum::Result.new(value: { ok: true }) }

      it 'should return the result' do
        expect(middleware.call(next_command, request: request))
          .to be == next_result
      end

      it 'should not update the native session' do
        middleware.call(next_command, request: request)

        expect(native_session).not_to have_received(:[]=)
      end
    end

    context 'when the next command returns a result with a token' do
      let(:token)       { '12345' }
      let(:next_result) { Cuprum::Result.new(value: { 'token' => token }) }

      it 'should return the result' do
        expect(middleware.call(next_command, request: request))
          .to be == next_result
      end

      it 'should update the native session' do
        middleware.call(next_command, request: request)

        expect(native_session)
          .to have_received(:[]=)
          .with('auth_token', token)
      end
    end
  end
end
