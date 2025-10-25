# frozen_string_literal: true

require 'rails_helper'

require 'cuprum/rails/rspec/deferred/controller_examples'

RSpec.describe Librum::Iam::View::UsersController, type: :controller do
  include Cuprum::Rails::RSpec::Deferred::ControllerExamples

  describe '.resource' do
    subject(:resource) { described_class.resource }

    it { expect(resource).to be_a Librum::Core::Resources::ViewResource }

    it { expect(resource.actions).to be == Set.new(%w[show]) }

    it { expect(resource.entity_class).to be == Librum::Iam::User }

    it { expect(resource.name).to be == 'user' }

    it { expect(resource.singular?).to be true }

    it 'should define the block component' do
      expect(resource.block_component)
        .to be Librum::Iam::View::Components::Users::Block
    end
  end

  describe '.responders' do
    include_deferred 'should respond to format',
      :html,
      using: Librum::Core::Responders::Html::ResourceResponder

    include_deferred 'should not respond to format', :json
  end

  include_deferred 'should define action',
    :show,
    Librum::Iam::Actions::Users::Show,
    member: false
end
