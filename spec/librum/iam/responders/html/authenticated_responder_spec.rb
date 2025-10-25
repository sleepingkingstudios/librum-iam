# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/rspec/deferred/responder_examples'

require 'librum/iam/rspec/deferred/responses/html_response_examples'

RSpec.describe Librum::Iam::Responders::Html::AuthenticatedResponder do
  include Cuprum::Rails::RSpec::Deferred::ResponderExamples
  include Librum::Iam::RSpec::Deferred::Responses::HtmlResponseExamples

  subject(:responder) { described_class.new(**constructor_options) }

  let(:described_class) { Spec::ExampleResponder }
  let(:resource_options) do
    { name: 'rockets' }
  end
  let(:constructor_options) do
    {
      action_name: action_name,
      controller:  controller,
      request:     request
    }
  end

  example_class 'Spec::ExampleResponder',
    Librum::Core::Responders::Html::ViewResponder \
  do |klass|
    klass.include Librum::Iam::Responders::Html::AuthenticatedResponder # rubocop:disable RSpec/DescribedClass
  end

  include_deferred 'should implement the Responder methods'

  describe '#call' do
    let(:response) { responder.call(result) }

    describe 'with a failing result with an AuthenticationError' do
      let(:error) do
        Librum::Core::Errors::AuthenticationError
          .new(message: 'Unable to log in')
      end
      let(:result) { Cuprum::Result.new(error: error) }

      include_deferred 'should render the login page'
    end
  end
end
