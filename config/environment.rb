# Load the rails application
require File.expand_path('../application', __FILE__)

PIVOTAL_TRACKER_URL = "http://www.pivotaltracker.com/services/v3"
PIVOTAL_TRACKER_API_KEY = "fe92da9b1a8932985b132e5e909de533" # Entryway
# PIVOTAL_TRACKER_API_KEY = "467bc905766e089b3c37d5fd7100ce62" # Vojto

HARVEST_SUBDOMAIN = "entryway"

# Initialize the rails application
Headwater::Application.initialize!
