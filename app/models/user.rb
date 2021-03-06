class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable and :oauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  field :name       
  
  field :harvest_username
  field :harvest_password
  
  references_many :time_entries
  references_many :stories

  def to_s
    email
  end
  
  def time_entries_today
    TimeEntry.started.where(:date => Date.today).order_by(:started_at => :desc)
  end
  
  def hours_this_week
    monday = Date.parse("monday")
    days = (monday..(monday+6)).to_a
    time_entries = TimeEntry.started.where(:date.in => days)
    time_entries.inject(0) { |sum, e| sum + e.hours }
  end
  
  def hours_today
    time_entries_today.inject(0) { |sum, e| sum + e.hours }
  end

end
