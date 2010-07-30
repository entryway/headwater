require "service"
require "synchronizer"

PIVOTAL_TRACKER_URL = "http://www.pivotaltracker.com/services/v3"
PIVOTAL_TRACKER_API_KEY = "fe92da9b1a8932985b132e5e909de533"

# Projects
@service = Service::RestService.new
@service.base_url = PIVOTAL_TRACKER_URL
@service.header['X-TrackerToken'] = PIVOTAL_TRACKER_API_KEY

