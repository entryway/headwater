module ActiveHarmony
  class ServiceManager
    # include Singleton
    
    ##
    # Initializes new Service Manager.
    def initialize
      @services = {}
    end
    
    ##
    # Adds service for identifier
    # @param [Service] Service
    # @param [Symbol] Identifier
    def add_service_for_identifier(service, identifier)
      @services[identifier] = service
    end
    
    ##
    # Returns service for identifier
    # @param [Symbol] identifier
    def service_with_identifier(identifier)
      service = @services[identifier]
      if service
        service
      else
        raise "There's no service with identifier #{identifier}"
      end
    end
  end
end