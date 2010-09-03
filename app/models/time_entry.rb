class TimeEntry
  include Mongoid::Document
  include Synchronizable
  
  field :date, :type => String
  field :started_at, :type => DateTime
  field :last_started_at, :type => DateTime
  field :is_running, :type => Boolean
  field :length, :type => Integer, :default => 0
  field :note, :type => String
  
  synchronizes_through Synchronizer::ServiceSynchronizer do |sync|
    sync.service = Service::RestService.new
    sync.service.base_url = "https://#{HARVEST_SUBDOMAIN}.harvestapp.com"
    sync.service.header['Accept'] = 'application/xml'
    sync.service.add_custom_url(:timeentry, :create, '/daily/add')
    sync.service.add_custom_url(:timeentry, :update, 'daily/update/:id', :post)
    sync.service.add_object_name(:timeentry, :create, 'request')
    sync.service.add_object_name(:timeentry, :update, 'request')
    sync.service.root = "add/day_entry"
    sync.factory = self
  end
  
  synchronize_field :notes => :push
  synchronize_field :hours => :push
  synchronize_field :spent_at => :push
  synchronize_field :project_id => :push
  synchronize_field :task_id => :push
  
  referenced_in :user
  referenced_in :story
  
  scope :started, :where => {:started_at.ne => nil}
  scope :archived, :where => {:length.exists => true, :started_at.ne => nil, :is_running.ne => true}
  # 
  def before_push(synchronizer)
    synchronizer.service.auth = {:username => user.harvest_username, :password => user.harvest_password}
  end
  
  def after_push(synchronizer)
    synchronizer.service.auth = nil
  end
  
  def notes
    "[##{story._remote_id}] #{story.name}"
  end
  
  def hours
    total_length.to_f / 60.to_f
  end
  
  def spent_at
    Date.parse(self.date)
  end
  
  def project_id
    story.project.harvest_project_id
  end
  
  def task_id
    story.project.harvest_task_id
  end
  
  def self.current_for_story_and_user(story, user)
    self.find_or_create_by({:date => Date.today.to_s, 
                            :story_id => story.id,
                            :user_id => user.id})
  end
  
  def self.new_for_story_and_user(story, user)
    entry = self.new
    entry.user = current_user
    # FIXME should work normally too
    if story
      story.time_entries << @entry
      story.save
    end
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