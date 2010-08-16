require "synchronizable"

class Story
  
  STATES = ['unscheduled', 'unstarted', 'started', 'finished', 'delivered', 'accepted']
  TYPES = ['feature', 'chore', 'bug']
  
  include Mongoid::Document
  include Synchronizable::PivotalTracker
  
  field :project_id, :type => Integer # reference to Project#_remote_id
  field :story_type
  field :url
  field :current_state
  field :description
  field :name
  field :requested_by
  field :owned_by
  field :created_at
  field :updated_at
  field :accepted_at
  field :notes, :type => Array
  field :tasks
  field :estimate
  field :labels
  field :deadline
  field :attachments, :type => Array
  
  field :state
  
  references_many :time_entries, :stored_as => :array, :inverse_of => :story
  
  synchronize_fields :project_id
  synchronize_fields :story_type
  synchronize_field :url => :pull
  synchronize_fields :current_state
  synchronize_fields :description
  synchronize_fields :name
  synchronize_fields :requested_by
  synchronize_fields :owned_by
  synchronize_fields :created_at
  synchronize_fields :updated_at
  synchronize_fields :accepted_at
  synchronize_fields :estimate
  synchronize_fields :labels
  synchronize_fields :deadline

  def project
    Project.where(:_remote_id => project_id).first
  end
  
  def current_state=(new_state)
    write_attribute :current_state, new_state
    if new_state == 'accepted'
      state = 'archived'
    elsif ['delivered', 'finished'].include?(new_state)
      state = 'done'
    elsif new_state == 'started'
      state = 'current'
    elsif ['unstarted', 'unscheduled', 'rejected'].include?(new_state)
      state = 'upcoming'
    end
    write_attribute :state, state
  end
  
  def state=(new_state)
    write_attribute :state, new_state
    if new_state == 'done'
      current_state = 'finished'
    elsif new_state == 'current'
      current_state = 'started'
    elsif new_state == 'archived'
      current_state = 'accepted'
    end
    write_attribute :current_state, current_state
  end
  
  def type
    story_type
  end
  
  def contexts
    {:projects => self.project_id}
  end
  
end