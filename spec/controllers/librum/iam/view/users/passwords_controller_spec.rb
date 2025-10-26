# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Librum::Iam::View::Users::PasswordsController,
  type: :controller \
do
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

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

    it { expect(resource.entity_class).to be resource_class }

    it { expect(resource.name).to be == 'password' }

    it { expect(resource.singular?).to be true }

    it 'should define the form component' do
      expect(resource.form_component)
        .to be Librum::Iam::View::Components::Users::Passwords::Form
    end
  end

  describe '.responders' do
    include_deferred 'should respond to format',
      :html,
      using: Librum::Core::Responders::Html::ResourceResponder

    include_deferred 'should not respond to format', :json
  end

  include_deferred 'should define action',
    :edit,
    Cuprum::Rails::Action,
    member: false

  include_deferred 'should define action',
    :update,
    Librum::Iam::Actions::Users::Passwords::Update,
    member: false
end
