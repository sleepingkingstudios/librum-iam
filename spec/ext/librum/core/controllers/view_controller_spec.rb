# frozen_string_literal: true

require 'cuprum/rails/rspec/deferred/controller_examples'

require 'rails_helper'

RSpec.describe Librum::Core::ViewController do # rubocop:disable RSpec/SpecFilePathFormat
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  include_deferred 'should define middleware',
    Librum::Iam::Authentication::Middleware::AuthenticateSession
end
