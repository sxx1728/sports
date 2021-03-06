#source 'https://rubygems.org'
source 'https://gems.ruby-china.com'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '6.0.0.rc1'

#gem 'mysql2'

gem 'sqlite3', '1.4.0'

# Use Puma as the app server
gem 'puma', '3.12.1'
# Use SCSS for stylesheets
gem 'sass-rails', '5.0.7'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '4.0.7'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '5.2.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.4.4', require: false

gem 'devise'
gem 'cancancan'
gem 'rolify'
gem "haml", "5.1.1"
gem 'http', "4.1.1"
gem 'rack-cors'
gem 'google-authenticator-rails'
gem 'base32', "~>0.3.2"
gem 'rqrcode'
gem 'base58'
gem 'will_paginate', "~> 3.1.7"
gem 'will_paginate-bootstrap', "~> 1.0.2"

gem 'eth', "0.4.12"
gem 'ethereum.rb'

gem 'rufus-scheduler'

gem 'grape', "~> 1.3.0"
gem 'grape-entity', "~> 0.7.1"
gem 'grape-swagger'
gem 'grape-swagger-entity', '~> 0.3'
gem 'grape-swagger-rails'

gem 'jwt'
gem 'carrierwave', '~> 2.0'
gem "mini_magick"
gem 'aasm'
gem 'wicked_pdf'
gem 'listen'
gem 'aliyunsdkcore'


group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'annotate'
  gem 'pry_debug'
  gem 'pry-nav'

  gem "capistrano", "~> 3.13", require: false
  gem 'capistrano-rvm',     require: false
  gem 'capistrano-rails',   require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma', require: false

end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
