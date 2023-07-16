# frozen_string_literal: true

module Librum::Iam
  # Adds middleware to authenticate the controller using the native session.
  module SessionMiddleware
    extend ActiveSupport::Concern

    included do
      middleware Librum::Iam::Authentication::Middleware::AuthenticateSession
    end
  end
end
