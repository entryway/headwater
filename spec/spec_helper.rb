require 'rubygems'


# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

require 'rspec/rails'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.


RSpec.configure do |config|
  config.mock_with :mocha
  config.include WebMock
  # config.include Capybara, :type => :integration
end
