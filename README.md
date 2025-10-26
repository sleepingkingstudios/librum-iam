# Librum::Iam

The IAM engine for the Librum application framework. Defines models, controllers, and middleware for authenticating and authorizing requests.

## License

The gem is available as open source software under the terms of the [GNU General Public License version 3](https://opensource.org/license/gpl-3-0/).

## Installation

1. Add the engine to the Gemfile:

    ```ruby
    # In Gemfile.rb

    gem 'librum-iam'
    ```

2. Install and run the migrations.

    ```bash
    bundle exec rails librum_iam:install:migrations
    bundle exec rake db:migrate
    ```

3. Set up the Sessions routes:

    ```ruby
    # In routes.rb

    scope :authentication, as: 'authentication' do
      resource :session,
        controller: 'librum/iam/view/sessions',
        only:       %i[create destroy]
    end
    ```

4. Configure `Librum::Iam` with the session path:

    ```ruby
    # In config/initializers/librum_iam.rb

    Rails.application.config.before_initialize do |app|
      app.config.authentication_session_path = '/authentication/session'
    end
    ```

5. (Optional) Define a `"login"` layout:

    ```html
    <!-- In app/views/layouts/login.html.erb -->

    <p>You are not currently logged in.</p>

    <%= render template: "layouts/application" %>
    ```

6. (Optional) Add Thor tasks:

    ```ruby
    # In tasks.thor

    require_relative 'config/environment'

    load 'librum/iam/tasks.thor'
    ```

7. (Optional) Create a new root user:

    ```bash
    bundle exec thor librum:iam:create_root_user
    ```
