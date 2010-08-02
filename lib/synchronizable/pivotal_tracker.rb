require "synchronizer"
require "service"

module Synchronizable
  module PivotalTracker
    def self.included(base)
      base.send :include, Synchronizable
      base.synchronizes_through Synchronizer::ServiceSynchronizer do |sync|
        sync.service = Service::RestService.new
        sync.service.base_url = PIVOTAL_TRACKER_URL
        sync.service.header['X-TrackerToken'] = PIVOTAL_TRACKER_API_KEY
        sync.factory = base
      end
    end
  end
end