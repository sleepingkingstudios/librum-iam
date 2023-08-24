# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::View::Users::PasswordsController,
  type: :controller \
do
  include Librum::Core::RSpec::Contracts::ControllerContracts

  describe '.resource' do
    subject(:resource) { described_class.resource }

    let(:base_path) do
      Librum::Iam::Engine.config.authentication_user_password_path
    end
    let(:resource_class) do
      Librum::Iam::PasswordCredential
    end

    it { expect(resource).to be_a Librum::Core::Resources::ViewResource }

    it { expect(resource.base_path).to be == base_path }

    it { expect(resource.resource_class).to be resource_class }

    it { expect(resource.resource_name).to be == 'password' }

    it { expect(resource.singular?).to be true }

    it 'should define the form component' do
      expect(resource.form_component)
        .to be Librum::Iam::View::Components::Users::Passwords::Form
    end
  end

  describe '.responders' do
    include_contract 'should respond to format',
      :html,
      using: Librum::Core::Responders::Html::ResourceResponder

    include_contract 'should not respond to format', :json
  end

  include_contract 'should define action',
    :edit,
    Cuprum::Rails::Action,
    member: false

  include_contract 'should define action',
    :update,
    Librum::Iam::Actions::Users::Passwords::Update,
    member: false
end
