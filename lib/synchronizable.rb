# require "synchronizable/base"
# require "synchronizable/pivotal_tracker"
# require "synchronizer"

module Synchronizable
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
    base.cattr_accessor :synchronizer
    base.field :_remote_id, :type => Integer
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
      self.find(:first, :conditions => {:_remote_id => id})
    end
  end
  
  module InstanceMethods
    def update_remote_id(id)
      self._remote_id = id
    end
  end
end