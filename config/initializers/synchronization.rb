# This is Harvest web service.
#
# It requires also authentication, but that differs
# by the story that's being synchronized.
# For that reason, authentication is handled in delegate
# methods of TimeEntry class.

harvest_service = ActiveHarmony::Service.new
harvest_service.base_url = "https://#{HARVEST_SUBDOMAIN}.harvestapp.com"
harvest_service.header['Accept'] = 'application/xml'
harvest_service.add_custom_url(:timeentry, :create, '/daily/add')
harvest_service.add_custom_url(:timeentry, :update, 'daily/update/:id', :post)
harvest_service.add_object_name(:timeentry, :create, 'request')
harvest_service.add_object_name(:timeentry, :update, 'request')
harvest_service.root = "add/day_entry"

TimeEntry.synchronizer = ActiveHarmony::Synchronizer.new
TimeEntry.synchronizer.factory = TimeEntry
TimeEntry.synchronizer.service = harvest_service
TimeEntry.synchronizer.configure do |config|
  config.push :notes
  config.push :hours
  config.push :spent_at
  config.push :project_id
  config.push :task_id
end