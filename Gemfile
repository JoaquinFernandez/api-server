source 'https://rubygems.org'
ruby '1.9.3'

gem 'rails', '4.1.5'
gem 'pg'

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
# For HTML parsing
gem 'nokogiri'
# For json response
gem 'json'
# For TZInfo
gem 'tzinfo-data'
# For managing the URIs
gem 'addressable'
# For the http/https requests
gem 'mechanize'

gem 'rabl'      # API builder
gem 'oj'        # JSON parser
gem 'httparty'  # Makes http requests incredibly easy
gem 'mail'      # Send Mails

gem 'kaminari'  # adds pagination to ActiveModels

gem 'sdoc', '~> 0.4.0',          group: :doc

group :development do
  gem 'powder'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'meta_request'
  gem 'xray-rails'

  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-minitest'
  gem 'guard-pow'
  gem 'guard-livereload'
  gem 'rack-livereload'
  gem 'ruby_gntp'

  gem 'html2haml'
  gem 'quiet_assets'
  gem 'spring'
end

group :development, :test do
  gem 'jazz_hands'
  gem 'ffaker'
  gem 'factory_girl_rails'
end

group :test do
  gem 'simplecov', :require => false
end
