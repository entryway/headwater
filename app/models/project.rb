require "synchronizable"

class Project
  
  include Mongoid::Document
  include Synchronizable::PivotalTracker
  
  field :name
  field :iteration_length
  field :week_start_day
  field :point_scale
  field :account
  field :velocity_scheme
  field :current_velocity
  field :initial_velocity
  field :number_of_done_iterations_to_show
  field :labels
  field :last_activity_at
  field :allow_attachments
  field :public
  field :use_https
  field :bugs_and_chores_are_estimatable
  field :commit_mode
  field :memberships
  field :integrations
  
  def stories
    Story.find(:all, :conditions => {:project_id => self._remote_id})
  end
  
  def id_string
    self.id.to_s
  end

end