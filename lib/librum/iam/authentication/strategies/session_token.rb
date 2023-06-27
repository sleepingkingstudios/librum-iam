# frozen_string_literal: true

require 'librum/iam/authentication/strategies'
require 'librum/iam/authentication/strategies/token'

module Librum::Iam::Authentication::Strategies
  # Authentication strategy for parsing an encoded JWT from a session.
  class SessionToken < Librum::Iam::Authentication::Strategies::Token
    class << self
      # @return true if the strategy is valid for the request; otherwise false.
      def matches?(session)
        session.key?('auth_token')
      end
      alias match? matches?
    end

    private

    attr_reader :session

    def find_token
      session['auth_token']
    end

    def process(session)
      @session = session

      super
    end
  end
end
