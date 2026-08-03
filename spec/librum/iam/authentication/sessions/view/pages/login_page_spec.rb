# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Sessions::View::Pages::LoginPage,
  framework: :bulma,
  type:      :component \
do
  subject(:component) { described_class.new(result:) }

  let(:result) { Cuprum::Result.new }

  describe '#call' do
    let(:snapshot) do
      <<~HTML
        <h1 class="title">
          Log In
        </h1>

        <form action="/authentication/session" accept-charset="UTF-8" method="post">
          <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

          <div class="field">
            <label class="label" for="username">
              Username
            </label>

            <div class="control has-icons-left">
              <input id="username" name="username" class="input" type="text">

              <span class="icon is-small is-left">
                <i class="fa-solid fa-user"></i>
              </span>
            </div>
          </div>

          <div class="field">
            <label class="label" for="password">
              Password
            </label>

            <div class="control has-icons-left">
              <input id="password" name="password" class="input" type="password">

              <span class="icon is-small is-left">
                <i class="fa-solid fa-key"></i>
              </span>
            </div>
          </div>

          <div class="field is-grouped mt-5">
            <p class="control">
              <button class="button is-primary" type="submit">
                Log In
              </button>
            </p>
          </div>
        </form>
      HTML
    end

    before(:example) do
      allow(Librum::Components::Bulma::Form)
        .to receive(:new)
        .and_wrap_original do |original, **options, &block|
          form = original.call(**options, &block)

          allow(form).to receive_messages(
            form_authenticity_token:  '12345',
            protect_against_forgery?: true
          )

          form
        end
    end

    include_deferred 'with components', Librum::Components::Bulma

    include_deferred 'with configuration',
      default_icon_family: 'font-awesome',
      icon_families:       %i[font-awesome]

    it { expect(rendered).to match_snapshot }
  end
end
