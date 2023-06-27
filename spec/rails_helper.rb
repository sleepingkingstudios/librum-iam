# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
if Rails.env.production?
  # :nocov:
  abort('The Rails environment is running in production mode!')
  # :nocov:
end

require 'rspec/rails'
require 'cuprum/rails/rspec/matchers'
require 'librum/core/rspec/component_helpers'
# Add additional requires below this line. Rails is not loaded until this point!

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  # :nocov:
  puts e.to_s.strip
  exit 1
  # :nocov:
end

RSpec.configure do |config|
  config.include Cuprum::Rails::RSpec::Matchers
  config.include Librum::Core::RSpec::ComponentHelpers, type: :component

  # ViewComponents delegate #respond_to? to their controller. This makes testing
  # their own instance methods difficult. The following stubs out this behavior
  # in tests and replaces it with the core Ruby behavior.
  config.before(:example, type: :component) do
    allow(subject).to receive(:respond_to?) \
    do |symbol, include_all = false|
      Object
        .instance_method(:respond_to?)
        .bind(subject)
        .call(symbol, include_all)
    end
  end

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
