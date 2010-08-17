# Load the rails application
require File.expand_path('../application', __FILE__)

PIVOTAL_TRACKER_URL = "http://www.pivotaltracker.com/services/v3"
PIVOTAL_TRACKER_API_KEY = "fe92da9b1a8932985b132e5e909de533"

HARVEST_SUBDOMAIN = "entryway"

# Initialize the rails application
Headwater::Application.initialize!
