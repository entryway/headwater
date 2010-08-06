class Queue::SynchronizationQueue
  include Singleton
  
  def run
    items = QueueItem.where(:state => "new").all
    puts items.count
    items.each do |item|
      process_item(item)
    end
  end
  
  def process_item(item)
    klass = item.object_type.constantize
    klass.synchronizer.service.set_contexts(item.contexts)
    item.result = klass.synchronizer.service.update(klass.synchronizer.object_name,
                                      item.object_remote_id,
                                      item.updates)
    klass.synchronizer.service.clear_contexts
    item.state = 'done'
    item.save
  end
end
