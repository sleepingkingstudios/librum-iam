# frozen_string_literal: true

require 'rails_helper'

require 'librum/core/rspec/contracts/model_contracts'

RSpec.describe Librum::Iam::User, type: :model do
  include Librum::Core::RSpec::Contracts::ModelContracts

  subject(:user) { described_class.new(attributes) }

  let(:attributes) do
    {
      email:    'alan.bradley@example.com',
      username: 'Alan Bradley',
      slug:     'alan-bradley',
      role:     described_class::Roles::USER
    }
  end

  describe '::Roles' do
    let(:expected_roles) do
      {
        GUEST:      'guest',
        USER:       'user',
        ADMIN:      'admin',
        SUPERADMIN: 'superadmin'
      }
    end

    include_examples 'should define immutable constant', :Roles

    it 'should enumerate the categories' do
      expect(described_class::Roles.all).to be == expected_roles
    end

    describe '::ADMIN' do
      it 'should store the value' do
        expect(described_class::Roles::ADMIN).to be == 'admin'
      end
    end

    describe '::GUEST' do
      it 'should store the value' do
        expect(described_class::Roles::GUEST).to be == 'guest'
      end
    end

    describe '::SUPERADMIN' do
      it 'should store the value' do
        expect(described_class::Roles::SUPERADMIN).to be == 'superadmin'
      end
    end

    describe '::USER' do
      it 'should store the value' do
        expect(described_class::Roles::USER).to be == 'user'
      end
    end
  end

  include_contract 'should be a model'

  ### Attributes
  include_contract 'should define attribute',
    :email,
    default: ''
  include_contract 'should define attribute',
    :role,
    default: ''
  include_contract 'should define attribute',
    :username,
    default: ''

  describe '#admin?' do
    include_examples 'should define predicate', :admin?, false

    describe 'with role: admin' do
      let(:attributes) { super().merge(role: described_class::Roles::ADMIN) }

      it { expect(user.admin?).to be true }
    end

    describe 'with role: guest' do
      let(:attributes) { super().merge(role: described_class::Roles::GUEST) }

      it { expect(user.admin?).to be false }
    end

    describe 'with role: superadmin' do
      let(:attributes) do
        super().merge(role: described_class::Roles::SUPERADMIN)
      end

      it { expect(user.admin?).to be false }
    end
  end

  describe '#guest?' do
    include_examples 'should define predicate', :guest?, false

    describe 'with role: admin' do
      let(:attributes) { super().merge(role: described_class::Roles::ADMIN) }

      it { expect(user.guest?).to be false }
    end

    describe 'with role: guest' do
      let(:attributes) { super().merge(role: described_class::Roles::GUEST) }

      it { expect(user.guest?).to be true }
    end

    describe 'with role: superadmin' do
      let(:attributes) do
        super().merge(role: described_class::Roles::SUPERADMIN)
      end

      it { expect(user.guest?).to be false }
    end
  end

  describe '#superadmin?' do
    include_examples 'should define predicate', :superadmin?, false

    describe 'with role: admin' do
      let(:attributes) { super().merge(role: described_class::Roles::ADMIN) }

      it { expect(user.superadmin?).to be false }
    end

    describe 'with role: guest' do
      let(:attributes) { super().merge(role: described_class::Roles::GUEST) }

      it { expect(user.superadmin?).to be false }
    end

    describe 'with role: superadmin' do
      let(:attributes) do
        super().merge(role: described_class::Roles::SUPERADMIN)
      end

      it { expect(user.superadmin?).to be true }
    end
  end

  describe '#user?' do
    include_examples 'should define predicate', :user?, true

    describe 'with role: admin' do
      let(:attributes) { super().merge(role: described_class::Roles::ADMIN) }

      it { expect(user.user?).to be false }
    end

    describe 'with role: guest' do
      let(:attributes) { super().merge(role: described_class::Roles::GUEST) }

      it { expect(user.user?).to be false }
    end

    describe 'with role: superadmin' do
      let(:attributes) do
        super().merge(role: described_class::Roles::SUPERADMIN)
      end

      it { expect(user.user?).to be false }
    end
  end

  describe '#valid?' do
    it { expect(user.valid?).to be true }

    include_contract 'should validate the format of',
      :email,
      message:     'must be an email address',
      matching:    {
        'user@example.com'             => 'an email address',
        'scoped.user@demo.example.com' => 'a scoped email address'
      },
      nonmatching: {
        'user'         => 'a plain string',
        '@'            => 'an @ sign',
        '@example.com' => 'a domain',
        'user@'        => 'a username'
      }
    include_contract 'should validate the presence of',
      :email,
      type: String
    include_contract 'should validate the uniqueness of',
      :email,
      factory_name: :user

    include_contract 'should validate the presence of',
      :role,
      type: String
    include_contract 'should validate the inclusion of',
      :role,
      in:        described_class::Roles.values,
      allow_nil: true

    include_contract 'should validate the format of',
      :slug,
      message:     'must be in kebab-case',
      matching:    {
        'example'               => 'a lowercase string',
        'example-slug'          => 'a kebab-case string',
        'example-compound-slug' => 'a kebab-case string with multiple words',
        '1st-example'           => 'a kebab-case string with digits'
      },
      nonmatching: {
        'InvalidSlug'   => 'a string with capital letters',
        'invalid slug'  => 'a string with whitespace',
        'invalid_slug'  => 'a string with underscores',
        '-invalid-slug' => 'a string with leading dash',
        'invalid-slug-' => 'a string with trailing dash'
      }
    include_contract 'should validate the presence of', :slug, type: String
    include_contract 'should validate the uniqueness of',
      :slug,
      factory_name: :user

    include_contract 'should validate the presence of',
      :username,
      type: String
    include_contract 'should validate the uniqueness of',
      :username,
      factory_name: :user
  end
end
