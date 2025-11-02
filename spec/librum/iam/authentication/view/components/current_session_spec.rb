# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::View::Components::CurrentSession,
  framework: :bulma,
  type:      :component \
do
  let(:config)     { Librum::Iam::Engine.config }
  let(:user)       { FactoryBot.build(:user, username: 'Alan Bradley') }
  let(:credential) { FactoryBot.build(:generic_credential, user:) }
  let(:session)    { Librum::Iam::Session.new(credential:) }

  include_deferred 'should be a view component'

  include_deferred 'should define component option',
    :destroy_path,
    default: -> { config.authentication_session_path },
    value:   '/session'

  include_deferred 'should define component option',
    :session,
    value: -> { session }

  include_deferred 'should define component option',
    :user_path,
    default: -> { config.authentication_user_path },
    value:   '/user'

  describe '.new' do
    include_deferred 'should validate the type of option',
      :destroy_path,
      allow_nil: true,
      expected:  String

    include_deferred 'should validate the type of option',
      :session,
      allow_nil: true,
      expected:  Librum::Iam::Session

    include_deferred 'should validate the type of option',
      :user_path,
      allow_nil: true,
      expected:  String
  end

  describe '#call' do
    let(:component_options) do
      # Override configuration-based defaults.
      super().merge(destroy_path: nil, session:, user_path: nil)
    end
    let(:snapshot) do
      <<~HTML
        <div class="level">
          <div class="level-left">
            <div class="level-item">
              <span>
                You are currently logged in as Alan Bradley.
              </span>
            </div>
          </div>
        </div>
      HTML
    end

    before(:example) do
      allow(Librum::Components::Bulma::Button)
        .to receive(:new)
        .and_wrap_original do |original, **options|
          button = original.call(**options)

          allow(button).to receive_messages(
            form_authenticity_token:  '12345',
            protect_against_forgery?: true
          )

          button
        end
    end

    include_deferred 'with configuration',
      default_icon_family: 'fa-solid',
      icon_families:       %i[fa-solid]

    include_deferred 'with components', Librum::Components::Bulma

    it { expect(rendered).to match_snapshot }

    describe 'with destroy_path: value' do
      let(:destroy_path)      { '/authentication/sessions' }
      let(:component_options) { super().merge(destroy_path:) }
      let(:snapshot) do
        <<~HTML
          <div class="level">
            <div class="level-left">
              <div class="level-item">
                <span>
                  You are currently logged in as Alan Bradley.
                </span>
              </div>
            </div>

            <div class="level-right">
              <div class="level-item">
                <form class="is-inline-block" action="/authentication/sessions" accept-charset="UTF-8" method="post">
                  <input type="hidden" name="_method" value="delete" autocomplete="off">

                  <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

                  <button class="button has-text-danger is-backgroundless is-borderless is-shadowless m-0 p-0 is-outlined" type="submit">
                    <span class="icon">
                      <i class="fa-solid fa-user-xmark"></i>
                    </span>

                    <span>
                      Log Out
                    </span>
                  </button>
                </form>
              </div>
            </div>
          </div>
        HTML
      end

      it { expect(rendered).to match_snapshot }
    end

    describe 'with user_path: value' do
      let(:user_path)         { '/user' }
      let(:component_options) { super().merge(user_path:) }
      let(:snapshot) do
        <<~HTML
          <div class="level">
            <div class="level-left">
              <div class="level-item">
                <span>
                  You are currently logged in as

                  <a href="/user">
                    Alan Bradley
                  </a>

                  .
                </span>
              </div>
            </div>
          </div>
        HTML
      end

      it { expect(rendered).to match_snapshot }
    end

    describe 'with multiple options' do
      let(:destroy_path)      { '/authentication/sessions' }
      let(:user_path)         { '/user' }
      let(:component_options) { super().merge(destroy_path:, user_path:) }
      let(:snapshot) do
        <<~HTML
          <div class="level">
            <div class="level-left">
              <div class="level-item">
                <span>
                  You are currently logged in as

                  <a href="/user">
                    Alan Bradley
                  </a>

                  .
                </span>
              </div>
            </div>

            <div class="level-right">
              <div class="level-item">
                <form class="is-inline-block" action="/authentication/sessions" accept-charset="UTF-8" method="post">
                  <input type="hidden" name="_method" value="delete" autocomplete="off">

                  <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

                  <button class="button has-text-danger is-backgroundless is-borderless is-shadowless m-0 p-0 is-outlined" type="submit">
                    <span class="icon">
                      <i class="fa-solid fa-user-xmark"></i>
                    </span>

                    <span>
                      Log Out
                    </span>
                  </button>
                </form>
              </div>
            </div>
          </div>
        HTML
      end

      it { expect(rendered).to match_snapshot }
    end
  end

  describe '#render?' do
    it { expect(component.render?).to be false }

    describe 'with session: value' do
      let(:component_options) { super().merge(session:) }

      it { expect(component.render?).to be true }
    end
  end
end
