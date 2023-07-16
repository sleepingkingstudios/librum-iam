# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::SessionMiddleware, type: :controller do
  include Librum::Core::RSpec::Contracts::ControllerContracts

  let(:described_class) { Spec::ExampleController }

  example_class 'Spec::ExampleController', Librum::Iam::ApplicationController \
  do |klass|
    klass.include Cuprum::Rails::Controller
    klass.include Librum::Iam::SessionMiddleware # rubocop:disable Rspec/DescribedClass
  end

  describe '.middleware' do
    include_contract 'should define middleware',
      Librum::Iam::Authentication::Middleware::AuthenticateSession
  end
end
