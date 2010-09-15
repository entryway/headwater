# encoding: utf-8

module ActiveHarmony
  class Synchronizer
    attr_accessor :factory, :service
    
    ##
    # Initializes new Service Synchronizer to do some
    # synchrinizing magic.
    def initialize
      @contexts = {}
    end
    
    ##
    # Returns object name for currently used factory
    # @return [Symbol] Object name
    def object_name
      @factory.object_name.to_sym
    end
    
    ##
    # Sets context for this synchronizer
    # @param [Symbol] Name of context
    # @param [String, Integer] Value
    def set_context(context_name, context_value)
      @contexts[context_name.to_sym] = context_value
    end
    
    ##
    # Pulls object from remote service
    # @param [Integer] Remote ID of object.
    # @return [Boolean] Result of pulling
    def pull_object(id)
      local_object = @factory.with_remote_id(id)
      if local_object
        # FIXME What if there's no local object and we still want to set some
        # contexts???
        @service.set_contexts(local_object.contexts)
      else
        local_object = @factory.new
      end
      local_object.before_pull(self) if local_object.respond_to?(:before_pull)
      object_hash = @service.show(object_name, id)
      @service.clear_contexts
      @factory.synchronizable_fields.each do |key|
        value = object_hash[key.to_s]
        local_object.send("#{key}=", value)
      end
      local_object.after_pull(self) if local_object.respond_to?(:after_pull)
      local_object.save
    end
    
    ##
    # Pushes local object to remote services.
    # Er, I mean, its attributes.
    # Like not object itself. Just attributes.
    # @param [Object] Local object
    def push_object(local_object)
      object_name = @factory.object_name.to_sym
      
      local_object.before_push(self) if local_object.respond_to?(:before_push)
      
      changes = {}
      @factory.synchronizable_fields(:push).each do |atr|
        value = local_object.send(atr)
        changes[atr.to_s] = value
      end
      
      @service.set_contexts(local_object.contexts)
      
      if local_object._remote_id
        @service.update(object_name, local_object._remote_id, changes)
      else
        result = @service.create(object_name, changes)
        if result
          local_object._remote_id = result['id']
          @factory.synchronizable_fields(:pull).each do |atr|
            local_object.write_attribute(atr, result[atr.to_s])
          end
          local_object.save
        end
      end
      
      local_object.after_push(self) if local_object.respond_to?(:after_push)
      @service.clear_contexts
    end
    
    ##
    # Pulls whole remote collection. If it cannot find
    # matching local object, it will create one. 
    # This method is slow, useful for initial import, not
    # for regular updates. For regular updates, only
    # changed remote objects should be updates using pull_object
    # @see pull_object
    def pull_collection
      @service.set_contexts(@contexts)
      collection = @service.list(object_name)
      @service.clear_contexts
      collection.each_with_index do |remote_object_hash, index|
        remote_id = remote_object_hash.delete("id")
        local_object = @factory.with_remote_id(remote_id)
        unless local_object
          local_object = @factory.new
          local_object.update_remote_id(remote_id)
        end
        local_object.before_pull(self) if local_object.respond_to?(:before_pull)
        local_object._collection_order = index
        fields = @factory.synchronizable_fields(:pull)
        fields.each do |field|
          value = remote_object_hash[field.to_s]
          local_object.send("#{field}=", value)
        end
        local_object.after_pull(self) if local_object.respond_to?(:after_pull)
        local_object.save
      end
      collection.count
    end
  end
end