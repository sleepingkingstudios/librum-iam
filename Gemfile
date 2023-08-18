# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in core.gemspec.
gemspec

gem 'cuprum',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/cuprum'
gem 'cuprum-collections',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/cuprum-collections'
gem 'cuprum-rails',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/cuprum-rails'
gem 'librum-core',
  branch: 'main',
  git:    'https://github.com/sleepingkingstudios/librum-core'

group :development, :test do
  gem 'annotate'

  gem 'byebug'

  # See https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md
  gem 'factory_bot_rails', '~> 6.2'

  gem 'rspec', '~> 3.10'
  gem 'rspec-rails', '~> 5.0'
  gem 'rspec-sleeping_king_studios', '~> 2.7'

  gem 'rubocop', '~> 1.49'
  gem 'rubocop-rails', '~> 2.19' # https://docs.rubocop.org/rubocop-rails/
  gem 'rubocop-rake', '~> 0.6'
  gem 'rubocop-rspec', '~> 2.19' # https://docs.rubocop.org/rubocop-rspec/

  gem 'simplecov', '~> 0.21'
end

group :development do
  gem 'sleeping_king_studios-tasks', '~> 0.4', '>= 0.4.1'
end
