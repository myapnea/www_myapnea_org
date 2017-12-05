# frozen_string_literal: true

source "https://rubygems.org"

gem "rails",                "5.2.0.beta2"

# Speed Up Loading Times
gem "bootsnap",             "1.1.5", require: false

# Database Adapter
gem "pg",                   "0.21.0"

# Gems used by project
gem "autoprefixer-rails"
gem "bootstrap",            "~> 4.0.0.beta2"
gem "carrierwave",          "~> 1.2.1"
# gem "devise",               "~> 4.3.0"
gem "devise", git: "https://github.com/plataformatec/devise", ref: "88e9a85"
gem "figaro",               "~> 1.1.1"
gem "font-awesome-rails",   "~> 4.7.0"
gem "haml",                 "~> 5.0.4"
gem "hashids",              "~> 1.0.3"
gem "jquery-ui-rails",      "~> 6.0.1"
gem "kaminari",             "~> 1.1.1"
gem "mini_magick"
gem "pg_search",            "~> 2.1.1"
gem "redcarpet",            "~> 3.4.0"
gem "rubyzip",              "~> 1.2.0"
gem "sitemap_generator",    "~> 6.0.0"

# Rails Defaults
gem "coffee-rails",         "~> 4.2"
gem "sass-rails",           "~> 5.0"
gem "uglifier",             ">= 1.3.0"

gem "jbuilder",             "~> 2.5"
gem "jquery-rails",         "~> 4.3.1"
gem "turbolinks",           "~> 5"

# Testing
group :test do
  gem "artifice"
  gem "minitest"
  gem "puma"
  gem "rails-controller-testing"
  gem "simplecov",          "~> 0.15.1", require: false
end

group :development do
  gem "web-console", "~> 3.0"
end

group :development, :test do
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"
end
