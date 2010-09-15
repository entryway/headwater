class HeadwaterSynchronization
  class << self
    
    def pull_if_needed
      pref = Preferences.instance
      last_pull = pref.value_for('headwater.synchronization.last_pull')
      if !last_pull || (Time.now - last_pull) > 240
        self.pull
      end
    end

    def pull
      pref = Preferences.instance
      pref.set_value_for 'headwater.synchronization.last_pull', Time.now
      
      Rails.logger.info "‹HeadwaterSynchronization / Pull› Starting\n"
      Project.synchronizer.pull_collection
      Project.all.each do |project|
        begin
          Rails.logger.info "‹HeadwaterSynchronization / Pull› Pulling project #{project.name}\n"
          Story.synchronizer.set_context :projects, project._remote_id
          Story.synchronizer.pull_collection
        rescue Exception => e
          Rails.logger.info "‹HeadwaterSynchronization / Pull› FAILED\n"
          Rails.logger.info "---------------------"
          Rails.logger.info e.message
          Rails.logger.info e.backtrace.join('\n')
          Rails.logger.info "---------------------"
        end
      end
      Rails.logger.info "‹HeadwaterSynchronization / Pull› Finished\n"
    end
    
  end
  
end