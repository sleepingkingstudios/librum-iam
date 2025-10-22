# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Sessions::Commands::Destroy do
  subject(:command) { described_class.new }

  describe '#call' do
    define_method :call_command do
      command.call
    end

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_any_keywords
    end

    it 'should return a passing result with nil value' do
      expect(call_command)
        .to be_a_passing_result
        .with_value(nil)
    end
  end
end
