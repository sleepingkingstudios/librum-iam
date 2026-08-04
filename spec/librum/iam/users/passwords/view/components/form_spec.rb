# frozen_string_literal: true

require 'rails_helper'

require 'stannum/errors'

RSpec.describe Librum::Iam::Users::Passwords::View::Components::Form,
  framework: :bulma,
  type:      :component \
do
  subject(:component) do
    described_class.new(resource:, result:, routes:, **component_options)
  end

  let(:resource) do
    Librum::Core::Resource.new(name: 'password', singular: true)
  end
  let(:result) { Cuprum::Rails::Result.new }
  let(:routes) do
    Cuprum::Rails::Routing::SingularRoutes
      .new(base_path: '/authentication/user/password')
  end

  describe '#call' do
    let(:snapshot) do
      <<~HTML
        <form action="/authentication/user/password" accept-charset="UTF-8" method="post">
          <input type="hidden" name="_method" value="patch" autocomplete="off">

          <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

          <div class="field">
            <label class="label" for="old_password">
              Old Password
            </label>

            <div class="control has-icons-left">
              <input id="old_password" name="old_password" class="input" type="password">

              <span class="icon is-small is-left">
                <i class="fa-solid fa-key"></i>
              </span>
            </div>
          </div>

          <div class="field">
            <label class="label" for="new_password">
              New Password
            </label>

            <div class="control has-icons-left">
              <input id="new_password" name="new_password" class="input" type="password">

              <span class="icon is-small is-left">
                <i class="fa-solid fa-key"></i>
              </span>
            </div>
          </div>

          <div class="field">
            <label class="label" for="confirm_password">
              Confirm Password
            </label>

            <div class="control has-icons-left">
              <input id="confirm_password" name="confirm_password" class="input" type="password">

              <span class="icon is-small is-left">
                <i class="fa-solid fa-key"></i>
              </span>
            </div>
          </div>

          <div class="field is-grouped mt-5">
            <p class="control">
              <button class="button is-primary" type="submit">
                Update Password
              </button>
            </p>

            <p class="control">
              <a class="button" href="/authentication/user">
                Cancel
              </a>
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

    context 'with a result with errors' do
      let(:error) do
        errors = Stannum::Errors.new

        errors['old_password'].add('spec.invalid', message: 'is invalid')
        errors['confirm_password']
          .add('spec.no_match', message: 'does not match')

        Cuprum::Rails::Errors::InvalidParameters.new(errors:)
      end
      let(:result) { Cuprum::Rails::Result.new(error:) }
      let(:snapshot) do
        <<~HTML
          <form action="/authentication/user/password" accept-charset="UTF-8" method="post">
            <input type="hidden" name="_method" value="patch" autocomplete="off">

            <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

            <div class="field">
              <label class="label" for="old_password">
                Old Password
              </label>

              <div class="control has-icons-left has-icons-right">
                <input id="old_password" name="old_password" class="input is-danger" type="password">

                <span class="icon is-small is-left">
                  <i class="fa-solid fa-key"></i>
                </span>

                <span class="icon is-small is-right">
                  <i class="fa-solid fa-circle-xmark"></i>
                </span>
              </div>

              <p class="help is-danger">
                is invalid
              </p>
            </div>

            <div class="field">
              <label class="label" for="new_password">
                New Password
              </label>

              <div class="control has-icons-left">
                <input id="new_password" name="new_password" class="input" type="password">

                <span class="icon is-small is-left">
                  <i class="fa-solid fa-key"></i>
                </span>
              </div>
            </div>

            <div class="field">
              <label class="label" for="confirm_password">
                Confirm Password
              </label>

              <div class="control has-icons-left has-icons-right">
                <input id="confirm_password" name="confirm_password" class="input is-danger" type="password">

                <span class="icon is-small is-left">
                  <i class="fa-solid fa-key"></i>
                </span>

                <span class="icon is-small is-right">
                  <i class="fa-solid fa-circle-xmark"></i>
                </span>
              </div>

              <p class="help is-danger">
                does not match
              </p>
            </div>

            <div class="field is-grouped mt-5">
              <p class="control">
                <button class="button is-primary" type="submit">
                  Update Password
                </button>
              </p>

              <p class="control">
                <a class="button" href="/authentication/user">
                  Cancel
                </a>
              </p>
            </div>
          </form>
        HTML
      end

      it { expect(rendered).to match_snapshot }
    end
  end
end
