# encoding: utf-8

require "spec_helper"
require "service"

module Service
  describe RestService do
    before :all do
      @service = Service::RestService.new
      @base_url = "http://chunky.bacon"
      @service.base_url = @base_url
    end
    
    ##
    # Initialization and configuration
    describe "#initialize" do
      it "should create new instance of Service::Rest" do
        @service.should be_a(Service::RestService)
      end
    end
  
    describe "#base_url=" do
      it "should set base url for the service" do
        @service.base_url = @base_url
        @service.base_url.should == @base_url
      end
    end
  
    describe "#header=" do
      it "should be empty hash as default" do
        @service.header.should == {}
      end
      
      it "should set extra headers for the service" do
        extra_header = {
          "Header name" => "Header Value"
        }
        @service.header = extra_header
        @service.header.should == extra_header
      end
    end
    
    describe "#set_header" do
      it "should set one header" do
        @service.set_header("test_header", "bla")
        @service.header["test_header"].should == "bla"
      end
    end
      
    ##
    # Generating URLs
    describe "#generate_rest_url" do
      it "should generate list url" do
        @service.generate_rest_url(:list, :my_object).should == \
          "#{@base_url}/my_objects"
      end
      
      it "should generate show url" do
        @service.generate_rest_url(:show, :my_object, 123).should == \
          "#{@base_url}/my_objects/123"
      end
      
      it "should generate update url" do
        pending
      end
      
      it "should generate destroy url" do
        pending
      end
    end
    
    describe "#generate_url" do
      it "should generate url for path" do
        @service.generate_url("rainbow").should == \
          "#{@base_url}/rainbow"
      end
      
      it "should generate url for path with slash at beginning" do
        @service.generate_url("/rainbow").should == \
          "#{@base_url}/rainbow"
      end
    end
    
    ##
    # Retrieving data
    describe "#retrieve" do
      it "should retrieve data from a url" do
        url = "http://chunky.bacon/foo.bar"
        response = "Chunky Bacon !!!"
        stub_request(:get, "http://chunky.bacon/foo.bar").to_return(:body => response)
        @service.retrieve(url).should == response
      end
      
      it "should use header while making the request" do
        url = "http://chunky.bacon/bar.foo"
        stub_request(:get, url).
          with(:headers => { 'Some-Header' => 'Some Value' }).
          to_return(:body => "Success!")
        @service.set_header 'Some-Header', 'Some Value'
        @service.retrieve(url).should == "Success!"
      end
    end
    
    describe "#list" do
      it "should list objects" do
        objects = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_objects type="array">
  <my_object>
    <id type="integer">1</id>
    <name>first</name>
  </my_object>
  <my_object>
    <id type="integer">2</id>
    <name>second</name>
  </my_object>
</my_objects>
EOF
        stub_request(:get, "http://chunky.bacon/my_objects").to_return(:body => objects)
        response = @service.list(:my_object)
        response.should == [
          {"id" => 1, "name" => "first"},
          {"id" => 2, "name" => "second"}
        ]
      end
    end
    
    describe "#show" do
      it "should show an object" do
        object = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_object>
  <id type="integer">1</id>
  <name>first</name>
</my_object>
EOF
        stub_request(:get, "http://chunky.bacon/my_objects/1").to_return(:body => object)
        response = @service.show(:my_object, 1)
        response.should == {"id" => 1, "name" => "first"}
      end
    end
    
    describe "#update" do
      it "should update object" do
        pending
      end
    end
    
    describe "#destroy" do
      it "should destroy object" do
        pending
      end
    end
  end
end