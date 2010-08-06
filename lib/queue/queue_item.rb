class Queue::QueueItem
  include Mongoid::Document

  field :type
  field :state
  field :result

  field :object_type
  field :object_remote_id

  field :updates, :type => Hash
  field :contexts, :type => Hash
end
