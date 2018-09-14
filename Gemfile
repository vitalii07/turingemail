source 'https://rubygems.org'

#ruby
ruby '2.1.5'
gem 'rails', '4.2.1' # Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'pg', '0.18.1' # Use postgres as the database for Active Record
gem 'devise'

##################
################## Server / Stack gems
##################

gem 'aws-sdk', '~> 1.59.0' # aws
gem 'foreman', '~> 0.73.0' # DO NOT change foreman version! Doing so causes strange errors.
gem 'unicorn', '~> 4.8.3'
gem 'newrelic_rpm'
gem 'dalli'
source "https://c6b8e099:3ccaa4e8@gems.contribsys.com/" do
  gem 'sidekiq-pro'
end
gem 'sidekiq-status'
gem 'sidekiq-failures'
gem 'redis-mutex'
gem 'sinatra', :require => nil
gem 'whenever', :require => false
gem 'health_check', :git => 'git://github.com/turinginc/health_check.git'

#Email attachments
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'mini_magick'

if ENV['NOT_HEROKU'].nil? # must use NOT_HEROKU because env not available in heroku compile
  gem 'rails_12factor', '~> 0.0.2', group: [:production, :staging]
end

gem "rails_config"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
#gem 'spring', group: :development # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#gem 'debugger', group: [:development, :test] # Use debugger

##################
################## API Support gems
##################

gem 'rest-client', '~> 1.7.2' # rest-client
gem 'google-api-client', '~> 0.8.6' # google api
gem 'rabl', '~> 0.9.3' # rabl
gem 'oj', '~> 2.7.2' # oj - needed for rabl
gem 'jbuilder', '~> 2.2.12' # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'twitter_oauth', '~> 0.4.94'
gem 'twitter', '~> 5.14.0'

# Customizable and sophisticated paginator
gem 'kaminari', '~> 0.16.3'

##################
################## Admin Panel Supoort gems
##################

gem 'upmin-admin'

##################
################## Docs And Report generators
##################

gem 'swagger-docs', '0.1.8' # swagger
gem 'sdoc', '~> 0.4.1', group: :doc # bundle exec rake doc:rails generates the API under doc/api.

##################
################## Performance Diagnostic gems
##################

gem 'rack-mini-profiler', require: false
gem 'flamegraph'
gem 'byebug'
gem 'pry-byebug'

group :development do
  gem 'railroady' #Draw Mode,C,V diagrams: Check Docs for more info how to use it
  gem "rubycritic", :require => false
  gem "better_errors" #This catches Rails Side Errors
  gem "binding_of_caller"
  gem 'traceroute' #This helps finding dead routes
  gem 'brakeman', :require => false
end

##################
################## Delayed job
##################

gem 'delayed_job', '~> 4.0.4'
gem 'delayed_job_active_record', '~> 4.0.2'
gem 'daemons'

##################
################## Email Support gems
##################

gem 'gmail_xoauth', '~> 0.4.1' # gmail oauth
gem 'premailer', '~> 1.8.2' # premailer
gem 'mail', '~> 2.5.4' # mail

##################
################## Ruby Addon gems
##################

gem 'andand', '~> 1.3.3' # The Maybe Monad in idiomatic Ruby

##################
################## Encrypt
##################

gem 'bcrypt', '~> 3.1.10' # Use ActiveModel has_secure_password
gem 'encryptor'

##################
################## Search
##################

gem 'hairtrigger'
gem 'gdata_19', '~>1.1.5'

##################
################## Assets
##################

# bootstrap
gem 'bootstrap-sass', '~> 3.2.0.1'
gem 'autoprefixer-rails', '~> 3.0.0.20140821'

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.0.3'
gem 'jquery-ui-rails', '~> 5.0.3'
gem 'ejs', '~> 1.1.1' # support for ejs
gem 'bower-rails', '~> 0.9.2'
gem 'simple_enum', '~> 2.0.0'
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '~> 2.7.1' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.1' # Use CoffeeScript for .js.coffee assets and views
gem 'turbolinks' # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

##################
################## Payments
##################

gem 'payola-payments'
gem 'ultrahook', group: :development

##################
################## Test Suites
##################

gem 'rspec-rerun'
gem 'rspec-legacy_formatters'

# rails testing
# keep in development for generators
group :test do
  gem 'capybara', '~> 2.4.4'
  gem 'capybara-webkit', '~> 1.5.0'
  gem 'selenium-webdriver', '~> 2.45.0'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'simplecov', require: false
  gem 'shoulda-matchers', require: false
  gem 'ffaker'
  gem 'test_after_commit'
  gem 'rspec-sidekiq'
end
group :development, :test do
  gem 'phantomjs', '~> 1.9.7.1'
  gem 'teaspoon', '~> 0.9.1'
  gem 'sinon-rails', '~> 1.10.3'
  gem 'jasmine-sinon-rails', '~> 1.3.4'
  gem 'annotate' # Annotates active record models and specs
  gem 'meta_request' # Profiler for ruby rack apps. Better than mini-profiler for api based apps. Need Rails panel to be added to chrome.
  gem "bullet", "~> 4.14.7" # Detect unused eager loading and N+1 queries
  gem 'quiet_assets' # Mutes assets pipeline log messages
  gem "rails_best_practices" # Code metric tool to check the quality of rails code
  gem "coffeelint"
  gem 'guard-rspec'
  gem 'guard-livereload'
  gem 'awesome_print'
  gem 'timecop'
  gem 'rspec-rails', '~> 3.0.1'
  gem 'factory_girl_rails', '4.4.1'
end
group :development do
  gem 'capistrano'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano3-unicorn'
  gem 'capistrano-rbenv', '~> 2.0'
  gem 'capistrano-rails-console'
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem 'capistrano-rails-collection'
  gem 'elbas', :git => 'git://github.com/turinginc/capistrano-elbas.git'
  gem 'guard-bundler'
  # gem 'guard-rails'
end
