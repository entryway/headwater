module Synchronizer
  class Queue
    include Singleton
  
    def queue_push(object)
      queue_item = QueueItem.new( :type => "push",
                                  :object_type => object.class.name,
                                  :object_local_id => object.id,
                                  :state => "new" )
      queue_item.save
    end
    
    def queue_pull(object_type, remote_id)
      queue_item = QueueItem.new( :type => "pull",
                                  :object_type => object_type,
                                  :object_remote_id => remote_id,
                                  :state => "new" )
      queue_item.save
    end
  
    def run
      items = QueueItem.where(:state => "new").all
      puts items.count
      items.each do |item|
        item.process_item
      end
    end
    
    def queued_items
      QueueItem.where(:state => "new").all
    end
    
    def should_run?
      queued_items.count > 0
    end
  end
end
