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
  field :hours_per_week
  
  field :harvest_project_id
  field :harvest_task_id
  
  synchronize_field :name
  synchronize_field :iteration_length
  synchronize_field :week_start_day
  synchronize_field :point_scale
  synchronize_field :account
  synchronize_field :velocity_scheme
  synchronize_field :current_velocity
  synchronize_field :initial_velocity
  synchronize_field :number_of_done_iterations_to_show
  synchronize_field :labels
  synchronize_field :last_activity_at
  synchronize_field :allow_attachments
  synchronize_field :public
  synchronize_field :use_https
  synchronize_field :bugs_and_chores_are_estimatable
  synchronize_field :commit_mode
  synchronize_field :memberships
  synchronize_field :integrations
  
  def stories
    Story.where(:project_id => self._remote_id).asc(:_collection_order)
  end
  
  def hours_this_week
    story_ids = self.stories.collect(&:id)
    monday = Date.parse("monday")
    days = (monday..(monday+6)).to_a
    time_entries = TimeEntry.archived.where(:date.in => days, :story_id.in => story_ids)
    time = 0
    time_entries.each { |e| time += e.hours }
    time
  end

end