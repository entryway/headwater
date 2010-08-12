class TimeEntry
  include Mongoid::Document
  
  field :started_at, :type => DateTime
  field :length, :type => Integer
  field :note, :type => String
  
  referenced_in :story
end