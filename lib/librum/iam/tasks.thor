# frozen_string_literal: true

require 'thor'

module Librum::Iam
  module Tasks
    # Command for generating a new root user.
    class CreateRootUser < Thor
      namespace 'librum:iam'

      desc 'create_root_user', 'Creates a new root user'
      long_desc <<~TEXT
        `librum:iam:create_root_user` will generate a new User and PasswordCredential,
        but only if there are no existing users.

        You will be prompted to enter the email address, username, and password for the
        new root user.
      TEXT
      def create_root_user # rubocop:disable Metrics/MethodLength
        unless users_collection.query.count.zero?
          error 'Failure: a Librum::Iam::User already exists.'

          return
        end

        username = ask_username
        email    = ask_email
        password = ask_password

        result   =
          create_user(email: email, password: password, username: username)

        if result.success?
          say "Successfully created user #{username}."
        else
          error "Failure: #{result.error&.message || 'something went wrong'}"
        end
      end

      private

      def ask_email
        repeat { ask "Enter email address:\n>" }
      end

      def ask_password # rubocop:disable Metrics/MethodLength
        repeat do
          password = repeat do
            say "Enter password:\n>"

            $stdin.noecho(&:gets).chomp
          end

          confirm = repeat do
            say "Confirm password:\n>"

            $stdin.noecho(&:gets).chomp
          end

          next password if password == confirm

          error 'Password does not match.'
        end
      end

      def ask_username
        repeat { ask "Enter username:\n>" }
      end

      def create_user(email:, password:, username:)
        Librum::Iam::Authentication::Users::CreateRootUser
          .new(repository: repository)
          .call(email: email, password: password, username: username)
      end

      def repeat
        value = nil

        loop do
          value = yield

          break value if value.present?
        end

        say ''

        value
      end

      def repository
        Cuprum::Rails::Repository.new
      end

      def users_collection
        repository.find_or_create(entity_class: Librum::Iam::User)
      end
    end
  end
end
