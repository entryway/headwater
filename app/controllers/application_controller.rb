class ApplicationController < ActionController::Base
  protect_from_forgery
  layout "application"
  
  after_filter do
    fork do
      result = Synchronizer::Queue.instance.run
      Rails.logger.info("Running queue: #{result.count}")
      HeadwaterSynchronization.pull_if_needed
    end
  end
end
