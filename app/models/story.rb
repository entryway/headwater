require "synchronizable"

class Story
  
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
  field :attachments
  
  field :state
  
  def current_state=(new_state)
    if ['accepted', 'delivered', 'finished'].include?(new_state)
      state = 'done'
    elsif new_state == 'started'
      state = 'current'
    elsif ['unstarted', 'unscheduled'].include?(new_state)
      state = 'upcoming'
    end
    self.state = state
  end
  
  def push
    synchronizer.set_context(:projects, self.project_id)
    synchronizer.push_object(self)
  end
  
end