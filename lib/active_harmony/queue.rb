module ActiveHarmony
  class Queue
    include Singleton
  
    ##
    # Queues object for push
    # @param [Object] Object
    def queue_push(object)
      queue_item = QueueItem.new( :kind => "push",
                                  :object_type => object.class.name,
                                  :object_local_id => object.id,
                                  :state => "new" )
      queue_item.save
    end
    
    ##
    # Queues object for pull
    # @param [Class] Class of object
    # @param [String] Remote ID for object
    def queue_pull(object_class, remote_id)
      queue_item = QueueItem.new( :kind => "pull",
                                  :object_type => object_class.name,
                                  :object_remote_id => remote_id,
                                  :state => "new" )
      queue_item.save
    end
  
    ##
    # Runs queue
    def run
      queued_items.each do |item|
        item.process_item
      end
    end
    
    ##
    # Returns queued items
    # @return [Array<QueueItem>] Queued Items
    def queued_items
      QueueItem.where(:state => "new").all
    end
    
    ##
    # Returns true if there are any items in queue
    # @return [Boolean] Should run
    def should_run?
      queued_items.count > 0
    end
  end
end
