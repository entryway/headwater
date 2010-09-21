module ActiveHarmony
  module Synchronizable
    module Core
      extend ActiveSupport::Concern
      
      included do
        cattr_accessor :synchronizer
        self.synchronizer = Synchronizer.new
        self.synchronizer.factory = self
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