# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Repository do
  subject(:repository) { described_class.new }

  describe '#find' do
    describe 'with qualified_name: "librum/iam/credentials"' do
      let(:collection) do
        repository.find(qualified_name: 'librum/iam/credentials')
      end

      it { expect(collection.entity_class).to be Librum::Iam::Credential }

      it { expect(collection.name).to be == 'librum/iam/credentials' }
    end

    describe 'with qualified_name: "librum/iam/users"' do
      let(:collection) do
        repository.find(qualified_name: 'librum/iam/users')
      end

      it { expect(collection.entity_class).to be Librum::Iam::User }

      it { expect(collection.name).to be == 'librum/iam/users' }
    end
  end
end
