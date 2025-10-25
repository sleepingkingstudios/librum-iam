# frozen_string_literal: true

Librum::Core::ViewController.class_eval do
  middleware Librum::Iam::Authentication::Middleware::AuthenticateSession
end
