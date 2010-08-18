class TimeEntry
  include Mongoid::Document
  include Synchronizable
  
  field :date, :type => String
  field :started_at, :type => DateTime
  field :last_started_at, :type => DateTime
  field :is_running, :type => Boolean
  field :length, :type => Integer, :default => 0
  field :note, :type => String
  field :story_id, :type => BSON::ObjectID
  
  synchronizes_through Synchronizer::ServiceSynchronizer do |sync|
    sync.service = Service::RestService.new
    sync.service.base_url = "http://#{HARVEST_SUBDOMAIN}.harvestapp.com"
    sync.service.header['Accept'] = 'application/xml'
    sync.service.add_path(:timeentry, :create, '/daily/add')
    sync.service.add_object_name(:timeentry, :create, 'request')
    sync.service.root = "timer/day_entry"
    sync.service.auth = {:username => "vojto@entryway.net", :password => "millennium"}
    sync.factory = self
  end
  
  synchronize_field :notes => :push
  synchronize_field :hours => :push
  synchronize_field :spent_at => :push
  synchronize_field :project_id => :push
  synchronize_field :task_id => :push
  
  scope :archived, :where => {:length.exists => true, :started_at.ne => nil, :is_running.ne => true}
  
  def notes
    note
  end
  
  def hours
    total_length.to_f / 60.to_f
  end
  
  def spent_at
    date
  end
  
  def project_id
    444267
  end
  
  def task_id
    356191
  end
  
  def story
    Story.find(story_id)
  end
  
  def self.pause_all
    self.where(:is_running => true).each do |entry|
      entry.pause
    end
  end
  
  def start
    return false if self.is_running
    self.class.pause_all
    self.length ||= 0
    self.is_running = true
    time = Time.now
    self.started_at = time
    self.last_started_at = time
    self.save
  end
  
  def current_length
    if is_running
      ((Time.now - self.last_started_at) / 60).round
    else
      0
    end
  end
  
  def total_length
    (length||0) + current_length
  end
  
  def pause
    self.length += self.current_length
    self.last_started_at = nil
    self.is_running = false
    self.save
  end
end