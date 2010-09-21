module ActiveHarmony
  class SynchronizerConfiguration
    TYPE_PUSH = :push
    TYPE_PULL = :pull
    TYPE_ALL = :all
    
    ##
    # Initializes new Synchronizer Configuration.
    def initialize
      @synchronizable_fields = []
    end
    
    ##
    # Configures field for push type of synchronization.
    # @param [Symbol] Field
    def push(field)
      synchronize field, :type => :push
    end
    
    ##
    # Configures field for pull type of synchronization.
    # @param [Symbol] Field
    def pull(field)
      synchronize field, :type => :pull
    end
    
    ##
    # Configures field for any type of synchronization.
    # If no type is specified, defaults to TYPE_ALL.
    # @param [Symbol] Field
    # @param [Hash] Options
    # @option Options [Symbol] :type Type of synchronization.
    def synchronize(field, options = {})
      options = {
        :type => TYPE_ALL
      }.merge(options)
      
      @synchronizable_fields << {
        :field => field,
        :type => options[:type]
      }
    end
    
    ##
    # Fields that should be synchronized on push type
    # @return [Array<Symbol>] Fields for push
    def synchronizable_for_push
      synchronizable_for_types([TYPE_PUSH, TYPE_ALL])
    end
    
    ##
    # Fields that should be synchronized on pull type
    # @return [Array<Symbol>] Fields for pull
    def synchronizable_for_pull
      synchronizable_for_types([TYPE_PULL, TYPE_ALL])
    end
    
    ##
    # Fields that should be synchronized on types specified
    # in argument
    # @param [Array<Symbol>] Types
    # @return [Array<Symbol>] Fields
    def synchronizable_for_types(types)
      @synchronizable_fields.select do |field_description|
        types.include?(field_description[:type])
      end.collect do |field_description|
        field_description[:field]
      end
    end
  end
end