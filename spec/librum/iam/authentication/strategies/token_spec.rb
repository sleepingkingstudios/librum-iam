# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Librum::Iam::Authentication::Strategies::Token do
  subject(:strategy) { described_class.new(repository: repository) }

  let(:repository) do
    Cuprum::Rails::Repository
      .new
      .tap do |repo|
        repo.find_or_create(record_class: Librum::Iam::Credential)
      end
  end
  let(:headers) { {} }
  let(:params)  { {} }
  let(:request) do
    instance_double(Cuprum::Rails::Request)
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:repository)
    end
  end

  describe '.matches?' do
    it { expect(described_class).to respond_to(:matches?).with(1).argument }

    it { expect(described_class).to have_aliased_method(:matches?).as(:match?) }

    it { expect(described_class.matches?(request)).to be false }
  end

  describe '#call' do
    let(:expected_error) do
      Librum::Iam::Authentication::Errors::MissingToken.new
    end

    it { expect(strategy).to be_callable.with(1).argument }

    it 'should return a failing result' do
      expect(strategy.call(request))
        .to be_a_failing_result
        .with_error(expected_error)
    end
  end

  describe '#repository' do
    include_examples 'should define reader', :repository, -> { repository }
  end
end
