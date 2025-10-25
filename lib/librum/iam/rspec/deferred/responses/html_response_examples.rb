# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred/provider'

require 'librum/core/rspec/deferred/responses/html_response_examples'

module Librum::Iam::RSpec::Deferred::Responses
  # Deferred examples for validating authenticated HTML responses.
  module HtmlResponseExamples
    include RSpec::SleepingKingStudios::Deferred::Provider
    include Librum::Core::RSpec::Deferred::Responses::HtmlResponseExamples

    deferred_examples 'should render the login page' do
      include_deferred 'should render component',
        Librum::Iam::View::Pages::LoginPage,
        assigns:     {},
        http_status: :unauthorized,
        layout:      'login',
        resource:    nil
    end
  end
end
