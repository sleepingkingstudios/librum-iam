# frozen_string_literal: true

require 'rails_helper'

require 'librum/iam/session'
require 'librum/iam/view/components/authentication/current_session'

RSpec.describe Librum::Iam::View::Components::Authentication::CurrentSession,
  type: :component \
do
  subject(:current_session) { described_class.new(session: session) }

  shared_context 'when initialized with a session' do
    let(:user)       { FactoryBot.create(:user, username: 'Alan Bradley') }
    let(:credential) { FactoryBot.create(:generic_credential, user: user) }
    let(:session)    { Librum::Iam::Session.new(credential: credential) }
  end

  let(:session) { nil }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:session)
    end
  end

  describe '#call' do
    let(:rendered) { render_inline(current_session) }
    let(:snapshot) do
      <<~HTML
        <div class="block user-session">
          <div class="icon-text">
            <span class="icon mr-1">
              <i class="fa-solid fa-user-xmark"></i>
            </span>

            <span>You are not currently logged in.
            </span>
          </div>
        </div>
      HTML
    end

    it { expect(rendered).to match_snapshot(snapshot) }

    describe 'with a session' do
      include_context 'when initialized with a session'

      let(:snapshot) do
        <<~HTML
          <div class="block user-session">
            <div class="icon-text">
              <span class="icon mr-1">
                <i class="fa-solid fa-user"></i>
              </span>

              <span>
                You are currently logged in as

                <a class="has-text-link" href="/authentication/user" target="_self">
                  Alan Bradley
                </a>
              </span>

              <form class="destroy_session_form" action="/authentication/session" accept-charset="UTF-8" method="post">
                <input type="hidden" name="_method" value="delete" autocomplete="off">

                <input type="hidden" name="authenticity_token" value="[token]" autocomplete="off">

                <div class="buttons is-right">
                  <input type="submit" name="commit" value="Log Out" class="button is-danger is-inverted" data-disable-with="Log Out">
                </div>
              </form>
            </div>
          </div>
        HTML
      end

      it { expect(rendered).to match_snapshot(snapshot) }
    end
  end

  describe '#current_user' do
    include_examples 'should define reader', :current_user

    wrap_context 'when initialized with a session' do
      it { expect(current_session.current_user).to be == credential.user }
    end
  end

  describe '#session' do
    include_examples 'should define reader', :session, nil

    wrap_context 'when initialized with a session' do
      it { expect(current_session.session).to be session }
    end
  end
end
