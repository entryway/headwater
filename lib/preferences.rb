class Preferences
  include Singleton
  
  def initialize
    db = Story.collection.db # FIXME should just use Rails environment db name
    @collection = db.collection('preferences')
  end
  
  def value_for(key)
    preference = document_for_key(key)
    if preference
      preference['value']
    end
  end
  
  def set_value_for(key, value)
    preference = document_for_key(key) || {:key => key}
    puts preference.inspect
    preference['value'] = value
    @collection.save(preference)
  end

  protected
  
  def document_for_key(key)
    preference = @collection.find({:key => key}).first
  end
end