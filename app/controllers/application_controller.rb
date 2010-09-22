class ApplicationController < ActionController::Base
  protect_from_forgery
  layout "application"
  
  after_filter do
    queue = ActiveHarmony::Queue.instance
    if queue.should_run?
      fork do
        result = queue.run
        Rails.logger.info("[Synchronization] Running queue: #{result.count}")
      end
    end
  end
end
