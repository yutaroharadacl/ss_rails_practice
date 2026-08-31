# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'concurrent-ruby', '1.3.4'
gem 'rails', '~> 6.0.6', '>= 6.0.6.1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.4.4'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
gem 'sidekiq'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Template engine
gem 'haml-rails'

# Bootstrap 3
gem 'bootstrap-sass', '~> 3.4'

# CoffeeScript (Sprockets経由)
gem 'coffee-rails', '~> 5.0'

# jQuery
gem 'jquery-rails'

# Backbone.js (Model/View/Router) + Underscore.js
gem 'backbone-rails'

# ページ遷移高速化（--skip-javascriptにより自動追加されなかったため明示的に追加）
gem 'turbolinks', '~> 5'

# テンプレート（Shopify系）
gem 'liquid'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rspec-rails'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen', '~> 3.2'
  gem 'rubocop', require: false
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'html2haml'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'brakeman', require: false
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
