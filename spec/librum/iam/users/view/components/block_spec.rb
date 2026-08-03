# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Users::View::Components::Block,
  framework: :bulma,
  type:      :component \
do
  subject(:component) { described_class.new(data:) }

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
    let(:snapshot) do
      <<~HTML
        <div class="fixed-grid has-0-cols has-4-cols-tablet has-6-cols-desktop">
          <div class="grid">
            <div class="cell has-text-weight-semibold">
              Username
            </div>

            <div class="cell is-col-span-3 is-col-span-5-desktop">
              Custom User
            </div>

            <div class="cell has-text-weight-semibold">
              Slug
            </div>

            <div class="cell is-col-span-3 is-col-span-5-desktop">
              custom-user
            </div>

            <div class="cell has-text-weight-semibold">
              Email
            </div>

            <div class="cell is-col-span-3 is-col-span-5-desktop">
              custom.user@example.com
            </div>

            <div class="cell has-text-weight-semibold">
              Role
            </div>

            <div class="cell is-col-span-3 is-col-span-5-desktop">
              User
            </div>
          </div>
        </div>

        <h2 class="title is-4">
          Security
        </h2>

        <p>
          <a class="icon-text" href="/authentication/user/password">
            <span class="icon">
              <i class="fa-solid fa-user-lock"></i>
            </span>

            Update Password
          </a>
        </p>
      HTML
    end

    include_deferred 'with components', Librum::Components::Bulma

    include_deferred 'with configuration',
      default_icon_family: 'font-awesome',
      icon_families:       %i[font-awesome]

    it { expect(rendered).to match_snapshot }
  end

  describe '#data' do
    include_examples 'should define reader', :data, -> { data }
  end
end
