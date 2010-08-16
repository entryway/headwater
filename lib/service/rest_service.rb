module Service
  class RestService < Base
    attr_accessor :base_url, :header, :root
    
    ##
    # Initializes new Rest Service
    def initialize
      @header = {}
      @contexts = {}
      @paths = []
      @root = nil
    end
    
    ##
    # Adds header
    # @param [String] Header name
    # @param [String] Header value
    def set_header(name, value)
      @header[name] = value
    end
    
    ##
    # Generates url for REST service
    # @param [Symbol] Action: show, list, update or destroy
    # @param [Symbol] Object type
    # @param [Integer] Object ID
    # @return [String] Generated URL
    def generate_rest_url(action, object_type, object_id = nil)
      path = path_for(object_type, action)
      unless path
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
      end
      
      return generate_url(path)
    end
    
    ##
    # Generates URL for path using base_url
    # @param [String] Path
    # @return [String] URL
    def generate_url(path)
      if path =~ /^\//
        path.sub!('/', '')
      end
      "#{@base_url}/#{path}"
    end
    
    ##
    # Retrieves data from URL
    # @param [String] URL
    # @return [String] Retrieved data from the URL
    def retrieve(url, method = :get, headers = {}, data = nil)
      # puts [url, method, headers, data].inspect
      data = retrieve_with_http(url, method, headers, data)
      # puts "\e\[32m"
      # puts data
      # puts "\e\[0m"
      data
    end
    
    def retrieve_with_typhoeus(url, method, headers, data)
      response = Typhoeus::Request.send(method, url, :headers => @header.merge(headers), :body => data)
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
    
    ##
    # Retrieves and parses XML data from URL
    # @param [String] URL
    # @return [Hash] Parsed XML data
    def retrieve_xml(url)
      data = retrieve(url)
      parse_xml(data)
    end
    
    ##
    # Parses XML
    # @param [String] XML
    # @return [Array<Hash>] Parsed XML in Ruby primitives
    def parse_xml(xml_string)
      Hash.from_xml(xml_string)
    end
    
    ##
    # List collection of remote objects
    # @param [Symbol] Object type
    # @return [Array<Hash>] Array of objects
    def list(object_type)
      url = generate_rest_url(:list, object_type)
      data = retrieve_xml(url)
      # FIXME FIXME FIXME: Not only list should use this, but
      # also show!!! ADD SPEC!!!
      if @root
        @root.split('/').each { |branch|
          data = data[branch]
        }
        data
      else
        data[object_type.to_s.pluralize]
      end
    end
    
    ##
    # Shows remote object
    # @param [Symbol] Object type
    # @param [Integer] Object ID
    # @return [Hash] Object
    def show(object_type, id)
      url = generate_rest_url(:show, object_type, id)
      data = retrieve_xml(url)
      data[object_type.to_s]
    end
    
    def update(object_type, id, data)
      url = generate_rest_url(:update, object_type, id)
      xml_data = data.to_xml(:root => object_type.to_s.gsub('-', '_'), :skip_instruct => true)
      result = retrieve(url, :put, {'Content-type' => 'application/xml'}, xml_data)
    end
    
    def create(object_type, data)
      url = generate_rest_url(:create, object_type)
      xml_data = data.to_xml(:root => object_type.to_s.gsub('-', '_'), :skip_instruct => true)
      result = retrieve(url, :post, {'Content-type' => 'application/xml'}, xml_data)
      data = parse_xml(result)
      data[object_type.to_s] # FIXME refactor this shit into a method
    end
    
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
    
    ##
    # Adds custom path
    # @param [Symbol] Object type
    # @param [Symbol] Action
    # @param [String] Path
    def add_path(object_type, action, path)
      @paths << {
        :object_type => object_type,
        :action => action,
        :path => path
      }
    end
    
    ##
    # Returns custom path
    # @params [Symbol] Object type
    # @param [Symbol] Action
    # @retun [String] Custom path
    def path_for(object_type, action)
      path = @paths.find do |path|
        path[:object_type] == object_type &&
        path[:action] == action
      end
      path ? path[:path] : nil
    end
  end
end