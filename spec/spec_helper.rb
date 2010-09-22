ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before :all do
    ActiveHarmony::QueueItem.delete_all
  end
  
  config.mock_with :mocha
  config.include WebMock
end
