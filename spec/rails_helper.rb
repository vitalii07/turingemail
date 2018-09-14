# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'shoulda/matchers'
require 'capybara/rails'
require 'database_cleaner'
require 'ffaker'
require 'sidekiq/testing'
require 'devise'
require 'support/controller_helpers'

Sidekiq::Testing.fake! # fake is the default mode
# Sidekiq::Testing.inline!
# Sidekiq::Testing.disable!

Capybara.server_host = 'localhost'
Capybara.server_port = 4001
Capybara.default_wait_time = 20
# Capybara.javascript_driver = ENV["CAPYBARA_JS_DRIVER"].try(:to_sym) || :webkit
Capybara.javascript_driver = :selenium

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
  ## rspec-sidekiq
  # Clears all job queues before each example
  # config.clear_all_enqueued_jobs = true # default => true
  # # Whether to use terminal colours when outputting messages
  # config.enable_terminal_colours = true # default => true
  # # Warn when jobs are not enqueued to Redis but to a job array
  # config.warn_when_jobs_not_processed_by_sidekiq = true # default => true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:each, :link_gmail_account => true) do
    capybara_signin_user(user)
    capybara_link_gmail()
  end

  config.after(:each, :link_gmail_account => true) do
    expect(user.destroy).not_to be(false)
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  #config.infer_spec_type_from_file_location!
end
