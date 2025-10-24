# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Core::Resource do
  it { expect(described_class).to be < Librum::Iam::Resource }
end
