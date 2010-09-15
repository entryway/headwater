module ActiveHarmony
  module Synchronizable
    module Core
      extend ActiveSupport::Concern
      
      included do
        cattr_accessor :synchronizer
        cattr_writer :synchronizable_fields
        send(:class_variable_set, :@@synchronizable_fields, [])
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
          fields.each do |field|
            if field.is_a?(Array)
              field.each { |f| self.synchronize_field(f)  }
            else
              self.synchronize_field(field)
            end
          end
        end
    
        ##
        # Sets synchronization of a single field
        def synchronize_field(field)
          fields = self.send(:class_variable_get, :@@synchronizable_fields)
          if field.is_a?(Hash)
            field, type = *field.to_a.first
          else
            type = :all
          end
          fields << {:field => field, :type => type}
        end
    
        ##
        # Returns fields that are being synchronized
        def synchronizable_fields(type = nil)
          fields = self.send(:class_variable_get, :@@synchronizable_fields)
          if type
            fields = fields.select do |field|
              field[:type] == type || field[:type] == :all
            end
          end
          fields.collect do |field|
            field[:field]
          end
        end
    
      

      end
  
      module InstanceMethods
      
    
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
          @queue ||= ActiveHarmony::Queue.instance
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
  end
end