module ActiveHarmony
  class Service
    attr_accessor :base_url, :header, :root, :auth
    
    ############################################################
    # Initialization & Configuration
    
    ##
    # Initializes new Rest Service
    def initialize
      @header = {}
      @contexts = {}
      @paths = []
      @object_names = []
      @root = nil
    end
    
    ##
    # Adds header
    # @param [String] Header name
    # @param [String] Header value
    def set_header(name, value)
      @header[name] = value
    end
    
    ############################################################
    # Generating URLs
    
    ##
    # Generates url for REST service
    # @param [Symbol] Action: show, list, update or destroy
    # @param [Symbol] Object type
    # @param [Integer] Object ID
    # @return [Service::ServiceUrl] Generated URL
    def generate_rest_url(action, object_type, object_id = nil)
      url = custom_url_for(object_type, action)
      
      method = if action == :list || action == :show
        :get
      elsif action == :create
        :post
      elsif action == :update
        :put
      end
      
      if url
        url.request_method ||= method
        if object_id
          url.path.sub!(':id', object_id.to_s)
        end
        return url if url
      end
      
      path = ''
      path += @contexts.collect { |name, value|
        "#{name}/#{value}"
      }.join('/')
      path += '/'
      if action == :list || action == :create
        path += object_type.to_s.pluralize
      elsif action == :show || action == :update
        path += "#{object_type.to_s.pluralize}/#{object_id.to_s}"
      end
      url = generate_url(path)
      
      ServiceUrl.new(url, method)
    end
    
    ##
    # Generates URL for path using base_url
    # @param [String] Path
    # @return [String] URL
    def generate_url(path)
      if path =~ /^\//
        path.sub!('/', '')
      end
      path = "#{@base_url}/#{path}"
    end
    
    ############################################################
    # Retrieving data from networks
    
    ##
    # Retrieves data from URL
    # @param [String] URL
    # @return [String] Retrieved data from the URL
    def retrieve(url, method = :get, headers = {}, data = nil)
      puts [url, method, headers, data].inspect
      if Rails.env.test?
        data = retrieve_with_http(url, method, headers, data)
      else
        data = retrieve_with_typhoeus(url, method, headers, data)
      end
      # puts "\e\[32m"
      # puts data
      # puts "\e\[0m"
      data
    end
    
    def retrieve_with_typhoeus(url, method, headers, data)
      request_options = {:headers => @header.merge(headers),
                        :body => data}
      request_options.merge!(auth) if auth
      # puts request_options
      response = Typhoeus::Request.send(method, url, request_options)
      response.body
    end
    
    def retrieve_with_http(url, method, headers, data)
      url = URI.parse(url)
      response = nil
      headers = @header.merge(headers)
      Net::HTTP.start(url.host, url.port) do |http|
        if method == :get
          response = http.get(url.path, headers).body
        elsif [:put, :post].include?(method)
          response = http.send(method, url.path, data, headers).body
        end
      end
      response
    end
    
    ############################################################
    # Parsing response
    
    ##
    # Parses XML
    # @param [String] XML
    # @return [Array<Hash>] Parsed XML in Ruby primitives
    def parse_xml(xml_string)
      return {} if xml_string.blank?
      begin
        Hash.from_xml(xml_string)
      rescue Exception => e
        return {}
      end
    end
    
    def find_object_in_result(result, object_type, action)
      data = result
      # puts result
      if @root
        @root.split('/').each do |branch|
          break if data.nil?
          data = data[branch]
        end
        data
      else
        path = if action == :list
          object_type.to_s.pluralize
        else
          object_type.to_s
        end
        data[path] # Pluralize? When? action?
      end
    end
    
    ############################################################
    # Working with REST services
    
    ##
    # List collection of remote objects
    # @param [Symbol] Object type
    # @return [Array<Hash>] Array of objects
    def list(object_type)
      url = generate_rest_url(:list, object_type)
      result = retrieve(url.path)
      parsed_result = parse_xml(result)
      find_object_in_result(parsed_result, object_type, :list)
    end
    
    ##
    # Shows remote object
    # @param [Symbol] Object type
    # @param [String] Object ID
    # @return [Hash] Object
    def show(object_type, id)
      url = generate_rest_url(:show, object_type, id)
      result = retrieve(url.path)
      parsed_result = parse_xml(result)
      find_object_in_result(parsed_result, object_type, :show)
    end
    
    ##
    # Updates remote object
    # @param [Symbol] Object type
    # @param [String] Object ID
    # @param [Hash] Data to be sent
    def update(object_type, id, data)
      url = generate_rest_url(:update, object_type, id)
      object_name = object_name_for(object_type, :update)
      xml_data = data.to_xml(:root => object_name, :skip_instruct => true, :dasherize => false)
      result = retrieve(url.path, url.method, {'Content-type' => 'application/xml'}, xml_data)
      find_object_in_result(result, object_type, :update)
    end
    
    ##
    # Creates a new remote object
    # @param [Symbol] Object type
    # @param [Hash] Data to be sent
    def create(object_type, data)
      url = generate_rest_url(:create, object_type)
      object_name = object_name_for(object_type, :create)
      xml_data = data.to_xml(:root => object_name, :skip_instruct => true, :dasherize => false)
      result = retrieve(url.path, url.method, {'Content-type' => 'application/xml'}, xml_data)
      parsed_result = parse_xml(result)
      find_object_in_result(parsed_result, object_type, :create)
    end
    
    ############################################################
    # Setting contexts
    
    ##
    # Set contexts for service
    # @param [Hash] Contexts
    def set_contexts(contexts)
      contexts.each do |name, value|
        @contexts[name.to_sym] = value
      end
    end
    
    ##
    # Clears contexts for service
    def clear_contexts
      @contexts = {}
    end
    
    ############################################################
    # Setting custom URLs
    
    ##
    # Adds custom path
    # @param [Symbol] Object type
    # @param [Symbol] Action
    # @param [String] Path
    def add_custom_url(object_type, action, path, method = nil)
      @paths << {
        :object_type => object_type,
        :action => action,
        :path => path,
        :method => method
      }
    end
    
    ##
    # Returns custom path
    # @param [Symbol] Object type
    # @param [Symbol] Action
    # @return [Service::ServiceUrl] Custom path
    def custom_url_for(object_type, action)
      path = @paths.find do |path|
        path[:object_type] == object_type &&
        path[:action] == action
      end
      if path
        ServiceUrl.new(generate_url(path[:path]), path[:method])
      end
    end
    
    ############################################################
    # Setting custom object names for objects
    
    ##
    # Adds new name for some type of object
    # @param [Symbol] Object type
    # @param [Symbol] Action
    # @param [String] New object name
    def add_object_name(object_type, action, new_object_name)
      @object_names << {
        :object_type => object_type,
        :action => action,
        :new_object_name => new_object_name.to_s
      }
    end
   
    ##
    # Returns custom object name for action
    # @param [Symbol] Object type
    # @param [Symbol] Action
    def object_name_for(object_type, action)
      object_name = @object_names.find do |object_name|
        object_name[:object_type] == object_type
        object_name[:action] == action
      end
      object_name = object_name ? object_name[:new_object_name] : nil
      unless object_name
        object_name = object_type.to_s.gsub('-', '_')
      end
      object_name
    end
  end
end