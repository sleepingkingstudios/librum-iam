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
        <div class="block content">
          <div class="columns mb-0">
            <div class="column is-2 has-text-weight-semibold mb-1">
              Username
            </div>

            <div class="column">
              Custom User
            </div>
          </div>

          <div class="columns mb-0">
            <div class="column is-2 has-text-weight-semibold mb-1">
              Slug
            </div>

            <div class="column">
              custom-user
            </div>
          </div>

          <div class="columns mb-0">
            <div class="column is-2 has-text-weight-semibold mb-1">
              Email
            </div>

            <div class="column">
              custom.user@example.com
            </div>
          </div>

          <div class="columns mb-0">
            <div class="column is-2 has-text-weight-semibold mb-1">
              Role
            </div>

            <div class="column">
              User
            </div>
          </div>
        </div>

        <h2 class="title is-4">Security</h2>

        <p>
          <a class="has-text-link" href="/authentication/user/password" target="_self">
            <span class="icon-text">
              <span class="icon">
                <i class="fas fa-user-lock"></i>
              </span>

              <span>Update Password</span>
            </span>
          </a>
        </p>
      HTML
    end

    it { expect(rendered).to match_snapshot(snapshot) }
  end

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end
end
