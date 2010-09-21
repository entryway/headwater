class TimeEntry
  include Mongoid::Document
  include ActiveHarmony::Synchronizable::Core
  include ActiveHarmony::Synchronizable::Mongoid
  
  field :date, :type => String
  field :started_at, :type => DateTime
  field :last_started_at, :type => DateTime
  field :is_running, :type => Boolean
  field :length, :type => Integer, :default => 0
  field :note, :type => String
  
  synchronizer.service = \
    SERVICE_MANAGER.service_with_identifier :harvest
  synchronizer.configure do |config|
    config.push :notes
    config.push :hours
    config.push :spent_at
    config.push :project_id
    config.push :task_id
  end
    
  referenced_in :user
  referenced_in :story
  
  scope :started, :where => {:started_at.ne => nil}
  scope :archived, :where => {:length.exists => true, :started_at.ne => nil, :is_running.ne => true}
  
  def self.total_hours(collection)
    collection.inject(0) { |sum, e| sum + e.hours }
  end
  
  def self.days_this_week
    monday = Date.parse("monday")
    return (monday..(monday+6)).to_a
  end
  
  scope :this_week, :where => {:date.in => self.days_this_week}
  
  def before_push(synchronizer)
    synchronizer.service.auth = {:username => user.harvest_username, :password => user.harvest_password}
  end
  
  def after_push(synchronizer)
    synchronizer.service.auth = nil
  end
  
  def notes
    notes = ""
    if story
      notes << "[##{story._remote_id}] #{story.name}"
    end
    if note
      notes << note
    end
    notes
  end
  
  def hours
    total_length.to_f / 60.to_f
  end
  
  def spent_at
    Date.parse(self.date)
  end
  
  def project_id
    story.project.harvest_project_id if story
  end
  
  def task_id
    story.project.harvest_task_id if story
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