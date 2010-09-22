class ApplicationController < ActionController::Base
  protect_from_forgery
  layout "application"
  
  after_filter :request_did_finish
  
  protected
  
  def request_did_finish
    perform_auto_push
  end
  
  def perform_auto_push
    unless HW_AUTO_PUSH
      Rails.logger.info("[Synchronization] Auto push is disabled.")
      return
    end
    queue = ActiveHarmony::Queue.instance
    if queue.should_run?
      fork do
        Rails.logger.info("[Synchronization] Running queue ...")
        result = queue.run
        Rails.logger.info("[Synchronization] Items processed: #{result.count}")
      end
    else
      Rails.logger.info("[Synchronization] Queue is empty.")
    end
  end
end