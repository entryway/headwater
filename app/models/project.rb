class Project
  
  include Mongoid::Document
  include ActiveHarmony::Synchronizable::Core
  include ActiveHarmony::Synchronizable::Mongoid
    
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
  field :hours_per_week, :type => Integer
  
  field :harvest_project_id
  field :harvest_task_id
  
  synchronizer.service = \
    SERVICE_MANAGER.service_with_identifier :tracker
  synchronizer.configure do |config|
    config.synchronize :name
    config.synchronize :iteration_length
    config.synchronize :week_start_day
    config.synchronize :point_scale
    config.synchronize :account
    config.synchronize :velocity_scheme
    config.synchronize :current_velocity
    config.synchronize :initial_velocity
    config.synchronize :number_of_done_iterations_to_show
    config.synchronize :labels
    config.synchronize :last_activity_at
    config.synchronize :allow_attachments
    config.synchronize :public
    config.synchronize :use_https
    config.synchronize :bugs_and_chores_are_estimatable
    config.synchronize :commit_mode
    config.synchronize :memberships
    config.synchronize :integrations
  end
  
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
  
  def progress_max
    10
  end
  
  def progress_actual
    ((progress_max*hours_this_week)/(hours_per_week.to_i)).ceil
  end

end