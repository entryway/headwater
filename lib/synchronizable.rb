# require "synchronizable/base"
# require "synchronizable/pivotal_tracker"
# require "synchronizer"

module Synchronizable
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.cattr_accessor :synchronizer
    base.cattr_accessor :synchronizable_fields
    base.synchronizable_fields = []
    base.field :_remote_id, :type => Integer
  end
  
  module ClassMethods
    def synchronizes_through(synchronizer_class)
      self.synchronizer = synchronizer_class.new
      yield(self.synchronizer) if block_given?
    end
    
    ##
    # Sets which fields should be synchronized
    # @param [Array<Symbol>] Fields
    def synchronize_fields(*fields)
      self.synchronizable_fields ||= []
      fields.each do |field|
        if field.is_a?(Array)
          field.each { |f| self.synchronizable_fields << f  }
        else
          self.synchronizable_fields << field
        end
      end
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
      updates = {}
      changes.each do |atr, values|
        next if atr == 'state' # FIXME Ignored attributes - somewhere else!
        updates[atr] = values[1]
      end
      updates
    end
    
    def contexts
      {}
    end

    # Returns Synchronization Queue
    def queue
      @queue ||= Synchronizer::Queue.instance
    end
    
    ##
    # Adds changes to queue
    # @param [Boolean] Instant push, don't wait for queue
    def push(instant = false)
      if instant
        synchronizer.push_object(self)
      else
        queue.queue_push(self)
      end
    end
    
    ##
    # Reteurns synchronizer
    def synchronizer
      self.class.synchronizer
    end
  end
end