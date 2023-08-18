# frozen_string_literal: true

require 'cuprum'
require 'cuprum/collections/commands/create'
require 'cuprum/collections/commands/find_one_matching'
require 'cuprum/collections/commands/update'

module Librum::Iam::Authentication::Passwords
  # Updates the password credential for the current user.
  class Update < Cuprum::Command
    # @param repository [Cuprum::Collections::Repository] the repository used to
    #   query the credential.
    # @param user [Librum::Iam::User] the user for whom the password credential
    #   should be updated.
    def initialize(repository:, user:)
      super()

      @repository = repository
      @user       = user
    end

    # @return [Cuprum::Collections::Repository] the repository used to query the
    #   credential.
    attr_reader :repository

    # @return [Librum::Iam::User] the user for whom the password credential
    #   should be updated.
    attr_reader :user

    private

    def create_credential(password:)
      attributes = {
        'active'             => true,
        'encrypted_password' => step { encrypt_password(password) },
        'expires_at'         => 1.year.from_now,
        'type'               => 'Librum::Iam::PasswordCredential',
        'user'               => user
      }

      Cuprum::Collections::Commands::Create
        .new(collection: credentials_collection)
        .call(attributes: attributes)
    end

    def credentials_collection
      repository.find_or_create(entity_class: Librum::Iam::Credential)
    end

    def deactivate_credential(credential:)
      Cuprum::Collections::Commands::Update
        .new(collection: credentials_collection)
        .call(
          attributes: { active: false },
          entity:     credential
        )
    end

    def encrypt_password(password)
      Librum::Iam::Authentication::Passwords::Generate
        .new
        .call(password)
    end

    def find_credential
      result = find_matching_credential

      return result if result.success?

      error =
        Librum::Iam::Authentication::Errors::MissingPassword
        .new(user_id: user.id)
      failure(error)
    end

    def find_matching_credential
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

    def process(new_password:, old_password:)
      credential = step { find_credential }

      step do
        validate_credential(credential: credential, password: old_password)
      end

      transaction do
        step { deactivate_credential(credential: credential) }

        step { create_credential(password: new_password) }
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

    def validate_credential(credential:, password:)
      Librum::Iam::Authentication::Passwords::Match
        .new(credential.encrypted_password)
        .call(password)
    end
  end
end
