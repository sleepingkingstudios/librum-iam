# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/view/pages/login_page'

RSpec.describe Librum::Iam::View::Pages::LoginPage, type: :component do
  subject(:page) { described_class.new(result) }

  let(:result) { Cuprum::Result.new }

  describe '#call' do
    let(:rendered) { render_inline(page) }
    let(:snapshot) do
      <<~HTML
        <h1 class="title">Log In</h1>

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
