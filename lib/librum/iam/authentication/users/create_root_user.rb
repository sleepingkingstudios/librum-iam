# frozen_string_literal: true

require 'cuprum'

module Librum::Iam::Authentication::Users
  # Creates a new root user and password if there are no users.
  class CreateRootUser < Cuprum::Command
    # @param repository [Cuprum::Collections::Repository] the data repository
    #   for users and credentials.
    def initialize(repository:)
      super()

      @repository = repository
    end

    # @return [Cuprum::Collections::Repository] the data repository for users
    #   and credentials.
    attr_reader :repository

    private

    def build_credential(password:, user:)
      attributes = {
        type:               'Librum::Iam::PasswordCredential',
        user_id:            user.id,
        expires_at:         1.year.from_now,
        encrypted_password: generate_password(password)
      }

      credentials_collection.build_one.call(attributes: attributes)
    end

    def build_user(email:, username:)
      attributes = {
        email:    email,
        role:     Librum::Iam::User::Roles::SUPERADMIN,
        slug:     generate_slug(username),
        username: username
      }

      users_collection.build_one.call(attributes: attributes)
    end

    def create_credential(password:, user:)
      credential = step { build_credential(password: password, user: user) }

      step { credentials_collection.validate_one.call(entity: credential) }

      step { credentials_collection.insert_one.call(entity: credential) }
    end

    def create_user(email:, username:)
      user = step { build_user(email: email, username: username) }

      step { users_collection.validate_one.call(entity: user) }

      step { users_collection.insert_one.call(entity: user) }
    end

    def credentials_collection
      repository.find_or_create(entity_class: Librum::Iam::Credential)
    end

    def generate_password(password)
      step { validate_password(password) }

      step do
        Librum::Iam::Authentication::Passwords::Generate.new.call(password)
      end
    end

    def generate_slug(username)
      step do
        Librum::Core::Models::Attributes::GenerateSlug.new.call(
          attributes: { name: username }
        )
      end
    end

    def process(email:, password:, username:)
      step { validate_first_user }

      transaction do
        user = step { create_user(username: username, email: email) }

        step { create_credential(password: password, user: user) }

        user
      end
    end

    def transaction(&block)
      result = nil

      Librum::Iam::Credential.transaction do
        result = steps(&block)

        raise ActiveRecord::Rollback if result.failure?
      end

      result
    end

    def users_collection
      repository.find_or_create(entity_class: Librum::Iam::User)
    end

    def validate_first_user
      return if users_collection.query.count.zero?

      error = Cuprum::Error.new(message: 'a Librum::Iam::User already exists')
      failure(error)
    end

    def validate_password(password)
      return if password.present?

      error = Cuprum::Error.new(message: "Password can't be blank")
      failure(error)
    end
  end
end
