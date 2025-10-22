# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Librum::Iam::SessionMiddleware, type: :controller do
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  let(:described_class) { Spec::ExampleController }

  example_class 'Spec::ExampleController', Librum::Iam::ApplicationController \
  do |klass|
    klass.include Cuprum::Rails::Controller
    klass.include Librum::Iam::SessionMiddleware # rubocop:disable RSpec/DescribedClass
  end

  describe '.middleware' do
    include_deferred 'should define middleware',
      Librum::Iam::Authentication::Middleware::AuthenticateSession
  end
end
