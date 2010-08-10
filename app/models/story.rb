require "synchronizable"

class Story
  
  STATES = ['unscheduled', 'unstarted', 'started', 'finished', 'delivered', 'accepted']
  
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
  
  synchronize_fields :project_id
  synchronize_fields :story_type
  synchronize_fields :url
  synchronize_fields :current_state
  synchronize_fields :description
  synchronize_fields :name
  synchronize_fields :requested_by
  synchronize_fields :owned_by
  synchronize_fields :created_at
  synchronize_fields :updated_at
  synchronize_fields :accepted_at
  synchronize_fields :notes
  synchronize_fields :tasks
  synchronize_fields :estimate
  synchronize_fields :labels
  synchronize_fields :deadline
  synchronize_fields :attachments
  
  def current_state=(new_state)
    write_attribute :current_state, new_state
    if ['accepted', 'delivered', 'finished'].include?(new_state)
      state = 'done'
    elsif new_state == 'started'
      state = 'current'
    elsif ['unstarted', 'unscheduled'].include?(new_state)
      state = 'upcoming'
    end
    self.state = state
  end
  
  def contexts
    {:projects => self.project_id}
  end
  
end