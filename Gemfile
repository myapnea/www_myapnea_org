source 'https://rubygems.org'

# Required in Rails 4 for logs to work on heroku production
# gem 'rails_12factor', group: :production
# gem 'airbrake'

gem 'thin'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use postgresql as the database for Active Record
gem 'pg'

# User HAML for views
gem 'haml'

# Debugging
gem 'byebug'

# Helps Store Secrets Securely for Heroku Deploys
gem 'figaro'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
# gem 'spring', group: :development

# Bootstrap and Styles
gem 'sass-rails', '~> 5.0'
gem 'bootstrap-sass'
# autoprefixer-rails 5.0.0 breaks, locking autoprefixer-rails to 4.0.2.2 for the time being
gem 'autoprefixer-rails', '4.0.2.2'
gem 'font-awesome-rails'

# Authentication
gem 'devise'

# Scaffold Generation
gem 'bootstrap-generators', '~> 3.2.0'

# Markdown Support
gem 'redcarpet', '~> 3.2.0'

# Directed Acyclic Graph
gem 'acts-as-dag'

# Authorization
gem 'rolify'
gem 'authority'

# Facebook
gem 'koala'

# Forum
gem 'forem', :github => "openpprn/forem", :branch => "rails-4.2"
gem 'kaminari', '~> 0.16.1'

# Blogs and Notifications
gem 'acts-as-taggable-on'

# User Profile
gem 'geocoder'
gem 'carrierwave'
gem 'mini_magick'


gem 'merit'

# For Third-Party API Connections
gem 'validic'
gem 'faraday'

# Development
group :development do
  gem "better_errors"
  gem "meta_request"
  gem "binding_of_caller"
end


# Testing
group :development, :test do
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'minitest-rails-capybara'
  gem 'selenium-webdriver'
end

gem 'simplecov', :require => false, :group => :test
