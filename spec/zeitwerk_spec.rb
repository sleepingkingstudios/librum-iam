# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Zeitwerk do
  it { expect { Rails.application.eager_load! }.not_to raise_error }
end
