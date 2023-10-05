# frozen_string_literal: true

require 'bcrypt'
require 'cuprum'

module Librum::Iam::Authentication::Passwords
  # Generates a BCrypt hash of the given raw password.
  class Generate < Cuprum::Command
    private

    def process(password)
      BCrypt::Password.create(password).to_s
    end
  end
end
