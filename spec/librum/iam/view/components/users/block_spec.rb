# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/view/components/users/block'

RSpec.describe Librum::Iam::View::Components::Users::Block, type: :component do
  subject(:block) { described_class.new(data: data) }

  let(:data) { FactoryBot.build(:user, username: 'Custom User') }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:data)
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:rendered) { render_inline(block) }
    let(:snapshot) do
      <<~HTML
        <div class="content">
          <div class="block">
            <p class="has-text-weight-semibold mb-1">Username</p>

            <p>
              Custom User
            </p>
          </div>

          <div class="block">
            <p class="has-text-weight-semibold mb-1">Slug</p>

            <p>
              custom-user
            </p>
          </div>

          <div class="block">
            <p class="has-text-weight-semibold mb-1">Email</p>

            <p>
              custom.user@example.com
            </p>
          </div>

          <div class="block">
            <p class="has-text-weight-semibold mb-1">Role</p>

            <p>
              User
            </p>
          </div>
        </div>
      HTML
    end

    it { expect(rendered).to match_snapshot(snapshot) }
  end

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end
end
