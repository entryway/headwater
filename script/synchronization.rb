require "service"
require "synchronizer"

Project.synchronizer.pull_collection

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