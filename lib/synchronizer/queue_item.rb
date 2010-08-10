module Synchronizer
  class QueueItem
    include Mongoid::Document

    field :type
    field :state
    field :result

    field :object_type
    field :object_remote_id
    field :object_local_id
      
    def process_item
      if type == "push"
        self.process_push
      elsif type == "pull"
        self.process_pull
      else
        raise "Unrecognized Queue type #{type}"
      end
    end
    
    def process_push
      factory = "::#{object_type}".constantize
      local_object = factory.find(object_local_id)
      syncer = factory.synchronizer
      syncer.push_object(local_object)
      
      self.state = 'done'
      self.save
    end
    
    def process_pull
      factory = "::#{object_type}".constantize
      syncer = factory.synchronizer
      syncer.pull_object(self.object_remote_id)
      
      self.state = 'done'
      self.save
    end
  end
end