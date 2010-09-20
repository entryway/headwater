module ActiveHarmony
  module Synchronizable
    module Mongoid
      extend ActiveSupport::Concern
      
      included do
        field :_remote_id, :type => Integer
        field :_collection_order, :type => Float, :default => 9999.0
      end
      
      module ClassMethods
        def object_name
          self.name.downcase
        end
    
        def with_remote_id(id)
          self.find(:first, :conditions => {:_remote_id => id.to_i})
        end
      end
      
      def update_remote_id(id)
        self._remote_id = id
      end
    
      def changed_attributes
        self.changes.keys
      end
    end
  end
end