module Synchronizer
  class QueueItem
    include Mongoid::Document

    field :kind
    field :state
    field :result

    field :object_type
    field :object_remote_id
    field :object_local_id
      
    def process_item
      if kind == "push"
        self.process_push
      elsif kind == "pull"
        self.process_pull
      else
        raise "Unrecognized Queue kind #{kind}"
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