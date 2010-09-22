require File.join(Rails.root, 'config', 'headwater.rb')

SERVICE_MANAGER = ActiveHarmony::ServiceManager.new

# Harvest
# ------------------------------------------
harvest_service = ActiveHarmony::Service.new
harvest_service.base_url = "https://#{HW_HARVEST_SUBDOMAIN}.harvestapp.com"
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
tracker_service.base_url = HW_PIVOTAL_TRACKER_URL
tracker_service.header['X-TrackerToken'] = HW_PIVOTAL_TRACKER_API_KEY
# Add service
SERVICE_MANAGER.add_service_for_identifier(tracker_service, :tracker)