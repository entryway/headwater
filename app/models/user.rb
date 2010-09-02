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

end
