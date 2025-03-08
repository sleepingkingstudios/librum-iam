# frozen_string_literal: true

require_relative 'lib/librum/iam/version'

Gem::Specification.new do |gem|
  gem.name        = 'librum-iam'
  gem.version     = Librum::Iam::VERSION
  gem.summary     =
    'Librum engine defining authentication and authorization.'

  description = <<~DESCRIPTION
    The IAM engine for the Librum application framework. Defines models,
    controllers, and middleware for authentication and authorizing requests.
  DESCRIPTION
  gem.description = description.strip.gsub(/\n +/, ' ')
  gem.authors     = ['Rob "Merlin" Smith']
  gem.email       = ['merlin@sleepingkingstudios.com']
  gem.homepage    = 'http://sleepingkingstudios.com'
  gem.license     = 'GPL-3.0-only'

  gem.metadata = {
    'allowed_push_host'     => 'none',
    'bug_tracker_uri'       => 'https://github.com/sleepingkingstudios/librum-iam/issues',
    'homepage_url'          => gem.homepage,
    'source_code_uri'       => 'https://github.com/sleepingkingstudios/librum-iam',
    'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '>= 3.3.0'
  gem.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'LICENSE.md', 'Rakefile', 'README.md']
  end

  gem.add_dependency 'librum-core'

  gem.add_dependency 'cuprum',       '~> 1.2'
  gem.add_dependency 'cuprum-rails', '~> 0.1'

  gem.add_dependency 'bcrypt', '~> 3.1.20'
  gem.add_dependency 'jwt', '~> 2.10'
  gem.add_dependency 'pg', '~> 1.5'
  gem.add_dependency 'rails', '~> 8.0.1'
  gem.add_dependency 'view_component', '~> 3.21'
end
