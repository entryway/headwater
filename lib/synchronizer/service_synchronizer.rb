module Synchronizer
  class ServiceSynchronizer < Synchronizer
    attr_accessor :factory, :service
    
    ##
    # Returns object name for currently used factory
    # @return [Symbol] Object name
    def object_name
      @factory.object_name.to_sym
    end
    
    ##
    # Pulls object from remote service
    # @param [Integer] Remote ID of object.
    # @return [Boolean] Result of pulling
    def pull_object(id)
      object_hash = @service.show(object_name, id)
      # Find object in Factory
      local_object = @factory.with_remote_id(id)
      object_hash.each do |key, value|
        unless key == "id"
          local_object.send("#{key}=", value)
        end
      end
      local_object.save
    end
    
    ##
    # Pushes local object to remote services.
    # Er, I mean, its attributes.
    # Like not object itself. Just attributes.
    # @param [Integer] Local ID of object.
    def push_object(id)
      object_name = @factory.object_name.to_sym
      local_object = @factory.with_local_id(id)
      changes = {} # ch-ch-ch-ch-chaaanges
      local_object.changed_attributes.each do |atr|
        value = local_object.send(atr)
        changes[atr.to_s] = value
      end
      
      # Update it remotely
      @service.update(object_name, id, changes)
    end
    
    ##
    # Pulls whole remote collection. If it cannot find
    # matching local object, it will create one. 
    # This method is slow, useful for initial import, not
    # for regular updates. For regular updates, only
    # changed remote objects should be updates using pull_object
    # @see pull_object
    def pull_collection
      collection = @service.list(object_name)
      collection.each do |remote_object_hash|
        remote_id = remote_object_hash.delete("id")
        local_object = @factory.with_remote_id(remote_id)
        local_object ||= @factory.new
        remote_object_hash.each do |key, value|
          local_object.send("#{key}=", value)
        end
        local_object.save
      end
    end
  end
end