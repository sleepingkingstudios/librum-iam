# frozen_string_literal: true

require 'cuprum'
require 'cuprum/collections/commands/find_one_matching'

module Librum::Iam::Authentication::Passwords
  # Finds the password credential for the requested user and matches passwords.
  class Find < Cuprum::Command
    # @param repository [Cuprum::Collections::Repository] the repository used to
    #   query the user and credential.
    def initialize(repository:)
      super()

      @repository = repository
    end

    # @return [Cuprum::Collections::Repository] the repository used to query the
    #   user and credential.
    attr_reader :repository

    private

    def credentials_collection
      repository.find_or_create(record_class: Librum::Iam::Credential)
    end

    def find_credential(user)
      Cuprum::Collections::Commands::FindOneMatching
        .new(collection: credentials_collection)
        .call(
          attributes: {
            active:  true,
            type:    'Librum::Iam::PasswordCredential',
            user_id: user.id
          }
        )
    end

    def find_user(username)
      Cuprum::Collections::Commands::FindOneMatching
        .new(collection: users_collection)
        .call(attributes: { username: username })
    end

    def process(password:, username:)
      steps do
        user       = step { find_user(username) }
        credential = step { find_credential(user) }

        step { validate_credential(credential: credential, password: password) }

        return credential
      end

      failure(Librum::Iam::Authentication::Errors::InvalidLogin.new)
    end

    def users_collection
      repository.find_or_create(record_class: Librum::Iam::User)
    end

    def validate_credential(credential:, password:)
      step { validate_expiration(credential) }

      Librum::Iam::Authentication::Passwords::Match
        .new(credential.encrypted_password)
        .call(password)
    end

    def validate_expiration(credential)
      return unless credential.expired?

      failure(Cuprum::Error.new(message: 'expired credential'))
    end
  end
end
