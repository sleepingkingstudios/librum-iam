# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::View::UsersController, type: :controller do
  include Librum::Core::RSpec::Contracts::ControllerContracts

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
    include_contract 'should respond to format',
      :html,
      using: Librum::Core::Responders::Html::ResourceResponder

    include_contract 'should not respond to format', :json
  end

  include_contract 'should define action',
    :show,
    Librum::Iam::Actions::Users::Show,
    member: false
end
