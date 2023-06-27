# frozen_string_literal: true

require 'rspec/sleeping_king_studios/contract'

require 'librum/core/rspec/contracts/model_contracts'
require 'librum/core/rspec/contracts/models/data_properties_contracts'

require 'librum/iam/rspec/contracts'

module Librum::Iam::RSpec::Contracts
  # RSpec contracts for Credential classes.
  module CredentialContracts
    include Librum::Core::RSpec::Contracts::ModelContracts
    include Librum::Core::RSpec::Contracts::Models::DataPropertiesContracts

    # Contract asserting that the class is a valid Credential.
    module ShouldBeACredentialContract
      extend RSpec::SleepingKingStudios::Contract

      contract do |type:, user_factory: :user|
        include_contract 'should be a model', slug: false

        ### Attributes
        include_contract 'should define attribute',
          :active,
          default: true
        include_contract 'should define attribute',
          :data,
          default: {}
        include_contract 'should define attribute', :expires_at

        include_contract 'should define data properties'

        describe '#type' do
          include_examples 'should define reader', :type, type
        end

        ### Associations
        include_contract 'should belong to',
          :user,
          factory_name: user_factory

        describe '#expired?' do
          include_examples 'should define predicate', :expired?

          context 'when expires_at is in the past' do
            let(:attributes) do
              super().merge(expires_at: 1.minute.ago)
            end

            it { expect(subject.expired?).to be true }
          end

          context 'when expires_at is in the future' do
            let(:attributes) do
              super().merge(expires_at: 1.minute.from_now)
            end

            it { expect(subject.expired?).to be false }
          end
        end

        describe '#valid?' do
          include_contract 'should validate the presence of', :active

          include_contract 'should validate the presence of', :expires_at

          include_contract 'should validate the presence of',
            :user,
            message: 'must exist'
        end
      end
    end
  end
end
