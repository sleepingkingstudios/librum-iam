# frozen_string_literal: true

module Librum::Iam
  # Methods for configuring controller authentication.
  module Resource
    # @param skip_authentication [true, false, Array<String, Symbol>] The
    #   specified actions (or all actions, if set to true) will be set to permit
    #   unauthenticated requests.
    # @param options [Hash<Symbol>] the default options for a resource.
    def initialize(skip_authentication: false, **)
      super(**)

      @skip_authentication =
        case skip_authentication
        when Array
          Set.new(skip_authentication.map(&:to_s))
        when String, Symbol
          Set.new([skip_authentication.to_s])
        else
          !!skip_authentication
        end
    end

    # @return [true, false, Set<String>] the specified actions (or all actions,
    #   if set to true) will be set to permit unauthenticated requests.
    attr_reader :skip_authentication

    # Checks if the specified action permits unauthenticated requests.
    #
    # @param action_name [String, Symbol] The name of the action.
    #
    # @return [true, false] true if the action permits unauthenticated requests;
    #   otherwise false.
    def skip_authentication_for?(action_name)
      return @skip_authentication unless @skip_authentication.is_a?(Set)

      @skip_authentication.include?(action_name.to_s)
    end
  end
end
