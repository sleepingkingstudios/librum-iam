# frozen_string_literal: true

require 'forwardable'

require 'cuprum/rails/request'

require 'librum/iam'

module Librum::Iam
  # A request wrapper with authenticaton session.
  class Request < Cuprum::Rails::Request
    extend Forwardable

    # @!attribute session
    #   @return [Librum::Iam::Session] the current authentication session.
    property :session

    def_delegators :session,
      :current_user
  end
end
