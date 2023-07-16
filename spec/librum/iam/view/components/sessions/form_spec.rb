# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::View::Components::Sessions::Form,
  type: :component \
do
  subject(:form) { described_class.new }

  describe '.new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#call' do
    let(:rendered) { render_inline(form) }
    let(:snapshot) do
      <<~HTML
        <form action="/authentication/session" accept-charset="UTF-8" method="post">
          <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

          <div class="field">
            <label for="username" class="label">Username</label>

            <div class="control has-icons-left">
              <input id="username" name="username" class="input" type="text">

              <span class="icon is-left is-small">
                <i class="fas fa-user"></i>
              </span>
            </div>
          </div>

          <div class="field">
            <label for="password" class="label">Password</label>

            <div class="control has-icons-left">
              <input id="password" name="password" class="input" type="password">

              <span class="icon is-left is-small">
                <i class="fas fa-key"></i>
              </span>
            </div>
          </div>

          <div class="field mt-5">
            <div class="control">
              <div class="columns">
                <div class="column is-half-tablet is-one-quarter-desktop">
                  <button type="submit" class="button is-primary is-fullwidth">Log In</button>
                </div>
              </div>
            </div>
          </div>
        </form>
      HTML
    end

    it { expect(rendered).to match_snapshot(snapshot) }
  end
end
