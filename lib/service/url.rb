module Service
  class Url
    attr_accessor :path, :request_method
    
    def initialize(path, request_method = :get)
      @path = path
      @request_method = request_method
    end
    
    def method
      request_method
    end
    
    def to_s
      path
    end
  end
end