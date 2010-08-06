# require "synchronizable/base"
# require "synchronizable/pivotal_tracker"
# require "synchronizer"

module Synchronizable
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.cattr_accessor :synchronizer
    base.field :_remote_id, :type => Integer
    base.before_save :push
  end
  
  module ClassMethods
    def synchronizes_through(synchronizer_class)
      self.synchronizer = synchronizer_class.new
      yield(self.synchronizer)
    end
    
    def object_name
      self.name.downcase
    end
    
    def with_remote_id(id)
      self.find(:first, :conditions => {:_remote_id => id.to_i})
    end

  end
  
  module InstanceMethods
    def update_remote_id(id)
      self._remote_id = id
    end
    
    def changed_attributes
      self.changes.keys
    end
    
    def updates
      updates = Hash[*changes.map { |atr, values| 
        [atr, values[1]]
      }.flatten]
      updates.delete('state')
      updates
    end
    
    def contexts
      {}
    end

    # Returns Synchronization Queue
    def queue
      @queue ||= Queue::SynchronizationQueue.instance
    end
    
    ##
    # Adds changes to queue
    # @param [Boolean] Instant push, don't wait for queue
    def push(instant = false)
      return if self.updates.empty?
      queue_item = Queue::QueueItem.new(:type => "push",
                                        :object_type => self.class.name,
                                        :object_remote_id => self._remote_id,
                                        :updates => self.updates,
                                        :contexts => self.contexts,
                                        :state => "new")
      queue_item.save
    end
    
    ##
    # Reteurns synchronizer
    def synchronizer
      self.class.synchronizer
    end
  end
end