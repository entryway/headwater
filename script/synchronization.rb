# encoding: utf-8

require "service"
require "synchronizer"

# Story.delete_all

Project.synchronizer.pull_collection

Project.all.each do |project|
  Story.synchronizer.set_context :projects, project._remote_id
    Story.synchronizer.pull_collection
end

# # Service
# @service = Service::RestService.new
# @service.base_url = PIVOTAL_TRACKER_URL
# @service.header['X-TrackerToken'] = PIVOTAL_TRACKER_API_KEY
# 
# # Synchronizer
# # - one for each entity? YES
# project_synchronizer = Synchronizer::ServiceSynchronizer.new
# project_synchronizer.factory = Project
# project_synchronizer.service = @service
# 
# project_synchronizer.pull_collection