class Story
  
  STATES = ['unscheduled', 'unstarted', 'started', 'finished', 'delivered', 'accepted']
  TYPES = ['feature', 'chore', 'bug']
  
  include Mongoid::Document
  #   include Synchronizable::PivotalTracker
  #   
  #   field :project_id, :type => Integer # reference to Project#_remote_id
  #   field :story_type
  #   field :url
  #   field :current_state
  #   field :description
  #   field :name
  #   field :requested_by
  #   field :owned_by
  #   field :created_at
  #   field :updated_at, :type => Time
  #   field :accepted_at
  #   field :notes, :type => Array
  #   field :tasks
  #   field :estimate
  #   field :labels
  #   field :tags, :type => Array, :default => []
  #   field :deadline
  #   field :attachments, :type => Array
  #   field :is_archived, :type => Boolean, :default => false
  #   
  #   field :state
  #   
  #   referenced_in :owner, :class_name => "User", :inverse_of => :stories
  #     
  #   synchronize_fields :project_id
  #   synchronize_fields :story_type
  #   synchronize_field :url => :pull
  #   synchronize_fields :current_state
  #   synchronize_fields :description
  #   synchronize_fields :name
  #   synchronize_fields :requested_by
  #   synchronize_fields :owned_by
  #   synchronize_fields :created_at
  #   synchronize_fields :updated_at
  #   synchronize_fields :accepted_at
  #   synchronize_fields :estimate
  #   synchronize_fields :labels
  #   synchronize_fields :deadline
  #   synchronize_fields :notes => :pull
  
  before_save do
    self.updated_at = Time.now
  end
  
  def after_pull(synchronizer)
    user = User.where(:name => self.owned_by).first
    update_attributes(:owner => user)
  end
  
  def before_push(synchronizer)
    if self.owner
      self.owned_by = self.owner.name
    end
    if ['chore', 'bug'].include?(self.story_type)
      self.estimate = -1
      if self.current_state == 'finished'
        self.current_state = 'accepted'
      end
    end
  end

  def project
    Project.where(:_remote_id => project_id).first
  end
  
  def archived_time_entries
    TimeEntry.archived.where(:story_id => self.id)
  end
  
  def time_entries
    TimeEntry.where(:story_id => self.id)
  end
  
  def current_state=(new_state)
    write_attribute :current_state, new_state
    if ['accepted', 'delivered', 'finished'].include?(new_state)
      state = 'done'
    elsif new_state == 'started'
      state = 'current'
    elsif ['unstarted', 'rejected'].include?(new_state)
      state = 'upcoming'
    elsif new_state == 'unscheduled'
      state = 'new'
    end
    write_attribute :state, state
  end
  
  def state=(new_state)
    write_attribute :state, new_state
    if new_state == 'done'
      current_state = 'finished'
    elsif new_state == 'current'
      current_state = 'started'
    elsif new_state == 'upcoming'
      current_state = 'unstarted'
    elsif new_state == 'new'
      current_state = 'unscheduled'
    end
    write_attribute :current_state, current_state
  end
  
  def type
    story_type
  end
  
  def contexts
    {:projects => self.project_id}
  end
  
  def labels=(labels)
    write_attribute :labels=, labels
    write_attribute :tags, (labels||"").split(/,\s*/)
  end
  
  def tags=(tags)
    tags_array = tags.split(/,\s*/)
    write_attribute :tags, tags_array
    write_attribute :labels, tags_array.join(',')
  end
  
end