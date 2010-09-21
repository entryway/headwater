PIVOTAL_TRACKER_URL = "http://www.pivotaltracker.com/services/v3"
PIVOTAL_TRACKER_API_KEY = "fe92da9b1a8932985b132e5e909de533" # Entryway
# PIVOTAL_TRACKER_API_KEY = "467bc905766e089b3c37d5fd7100ce62" # Vojto
HARVEST_SUBDOMAIN = "entryway"

SERVICE_MANAGER = ActiveHarmony::ServiceManager.new

# Harvest
# ------------------------------------------
harvest_service = ActiveHarmony::Service.new
harvest_service.base_url = "https://#{HARVEST_SUBDOMAIN}.harvestapp.com"
harvest_service.header['Accept'] = 'application/xml'
harvest_service.add_custom_url(:timeentry, :create, '/daily/add')
harvest_service.add_custom_url(:timeentry, :update, 'daily/update/:id', :post)
harvest_service.add_object_name(:timeentry, :create, 'request')
harvest_service.add_object_name(:timeentry, :update, 'request')
harvest_service.root = "add/day_entry"
# Add service
SERVICE_MANAGER.add_service_for_identifier(harvest_service, :harvest)



# Pivotal Tracker
# ------------------------------------------
tracker_service = ActiveHarmony::Service.new
tracker_service.base_url = PIVOTAL_TRACKER_URL
tracker_service.header['X-TrackerToken'] = PIVOTAL_TRACKER_API_KEY
# Add service
SERVICE_MANAGER.add_service_for_identifier(tracker_service, :tracker)