# frozen_string_literal: true

require 'rails_helper'

require 'stannum/errors'

RSpec.describe Librum::Iam::View::Components::Users::Passwords::Form,
  type: :component \
do
  include Librum::Core::RSpec::ComponentHelpers

  subject(:form) { described_class.new(errors: errors) }

  shared_context 'with errors' do
    let(:errors) do
      err = Stannum::Errors.new

      err['old_password'].add('spec.invalid', message: 'is invalid')
      err['confirm_password'].add('spec.no_match', message: 'does not match')

      err
    end
  end

  let(:errors) { nil }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors)
        .and_any_keywords
    end
  end

  describe '#call' do
    let(:rendered) { render_inline(form) }
    let(:snapshot) do
      <<~HTML
        <form action="/authentication/user/password" accept-charset="UTF-8" method="post">
          <input type="hidden" name="_method" value="patch" autocomplete="off">

          <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

          <div class="field">
            <label for="old_password" class="label">Old Password</label>

            <div class="control">
              <input id="old_password" name="old_password" class="input" type="password">
            </div>
          </div>

          <div class="field">
            <label for="new_password" class="label">New Password</label>

            <div class="control">
              <input id="new_password" name="new_password" class="input" type="password">
            </div>
          </div>

          <div class="field">
            <label for="confirm_password" class="label">Confirm Password</label>

            <div class="control">
              <input id="confirm_password" name="confirm_password" class="input" type="password">
            </div>
          </div>

          <div class="field mt-5">
            <div class="control">
              <div class="columns">
                <div class="column is-half-tablet is-one-quarter-desktop">
                  <button type="submit" class="button is-primary is-fullwidth">Update Password</button>
                </div>

                <div class="column is-half-tablet is-one-quarter-desktop">
                  <a class="button is-fullwidth has-text-black" href="/authentication/user" target="_self">
                    Cancel
                  </a>
                </div>
              </div>
            </div>
          </div>
        </form>
      HTML
    end

    it { expect(rendered).to match_snapshot(snapshot) }

    wrap_context 'with errors' do
      let(:snapshot) do
        <<~HTML
          <form action="/authentication/user/password" accept-charset="UTF-8" method="post">
            <input type="hidden" name="_method" value="patch" autocomplete="off">

            <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

            <div class="field">
              <label for="old_password" class="label">Old Password</label>

              <div class="control has-icons-right">
                <input id="old_password" name="old_password" class="input is-danger" type="password">

                <span class="icon is-right is-small">
                  <i class="fas fa-triangle-exclamation"></i>
                </span>
              </div>

              <p class="help is-danger">is invalid</p>
            </div>

            <div class="field">
              <label for="new_password" class="label">New Password</label>

              <div class="control">
                <input id="new_password" name="new_password" class="input" type="password">
              </div>
            </div>

            <div class="field">
              <label for="confirm_password" class="label">Confirm Password</label>

              <div class="control has-icons-right">
                <input id="confirm_password" name="confirm_password" class="input is-danger" type="password">

                <span class="icon is-right is-small">
                  <i class="fas fa-triangle-exclamation"></i>
                </span>
              </div>

              <p class="help is-danger">does not match</p>
            </div>

            <div class="field mt-5">
              <div class="control">
                <div class="columns">
                  <div class="column is-half-tablet is-one-quarter-desktop">
                    <button type="submit" class="button is-primary is-fullwidth">Update Password</button>
                  </div>

                  <div class="column is-half-tablet is-one-quarter-desktop">
                    <a class="button is-fullwidth has-text-black" href="/authentication/user" target="_self">
                      Cancel
                    </a>
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

  describe '#errors' do
    include_examples 'should define reader', :errors, nil

    wrap_context 'with errors' do
      it { expect(form.errors).to be == errors }
    end
  end
end
