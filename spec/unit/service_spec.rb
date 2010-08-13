# encoding: utf-8

require "spec_helper"
require "service"
require "webmock/rspec"

module Service
  describe RestService do
    before :each do
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
        @service.generate_rest_url(:update, :my_object, 123).should == \
          "#{@base_url}/my_objects/123"
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
        response = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_object>
  <id type="integer">1</id>
  <name>updated name</name>
</my_object>
EOF
        changes = {'name' => 'updated name'}
        expected_headers = {'Content-type' => 'application/xml'}
        expected_data    = '<?xml version="1.0" encoding="UTF-8"?>
<my-object>
  <name>updated name</name>
</my-object>'
        expected_url = 'http://chunky.bacon/my_objects/123'
        stub_request(:put, expected_url)
        @service.update(:my_object, 123, changes)
        request(:put, expected_url).with(:body => /<name>updated name<\/name>/).should have_been_made
        # FIXME Add specs that checks for hash in response
      end
    end
    
    describe "#create" do
      it "should create object" do
        response = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_object>
  <id type="integer">1</id>
  <name>new name</name>
</my_object>
EOF
        changes = {'name' => 'new name'}
        expected_headers = {'Content-type' => 'application/xml'}
        expected_url = 'http://chunky.bacon/my_objects'
        stub_request(:post, expected_url).to_return(:body => response)
        result = @service.create(:my_object, changes)
        request(:post, expected_url).with(:body => /<name>new name<\/name>/).should have_been_made
        result.should == {'id' => 1, 'name' => 'new name'}
      end
    end
    
    describe "#destroy" do
      it "should destroy object" do
        pending
      end
    end
    
    describe "#set_contexts" do
      it "should generate url with contexts in it" do
        @service.set_contexts({
          :first_context => 123,
          :second_context => 456
        })
        url = @service.generate_rest_url(:list, :bacon)
        url.should == "http://chunky.bacon/first_context/123/second_context/456/bacons"
      end
    end
    
    describe "#clear_contexts" do
      it "should reset contexts on a service" do
        @service.set_contexts({
          :first_context => 123,
          :second_context => 456
        })
        url = @service.generate_rest_url(:list, :bacon)
        url.should == "http://chunky.bacon/first_context/123/second_context/456/bacons"
        @service.clear_contexts
        url = @service.generate_rest_url(:list, :bacon)
        url.should == "http://chunky.bacon/bacons"
      end
    end
    
    context "with custom path" do
      before :each do
        @service.add_path(:my_object, :list, "my_objects/all")
      end
      
      describe "#add_path" do
        it "should use custom path for specific object/action" do
          @service.generate_rest_url(:list, :my_object).should == "http://chunky.bacon/my_objects/all"
        end
      end

      describe "#path_for" do
        it "should find custom path" do
          @service.path_for(:my_object, :list).should == "my_objects/all"
        end
      end
    end
    
    context "with custom root" do
      before :each do
        @service.root = "things/hidden/somewhere/my_objects"
      end
      
      describe "#list" do
        it "should list" do
          object = <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <things>
    <hidden>
      <somewhere>
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
      </somewhere>
    </hidden>
  </things>
  EOF
          stub_request(:get, "http://chunky.bacon/my_objects").to_return(:body => object)
          response = @service.list(:my_object)
          response.should == [
            {"id" => 1, "name" => "first"},
            {"id" => 2, "name" => "second"}
          ]
        end
      end
      
      describe "#show" do
        it "should show" do
          object = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<things>
<hidden>
  <somewhere>
    <my_object>
      <id type="integer">1</id>
      <name>updated name</name>
    </my_object>
  </somewhere>
</hidden>
</things>
EOF
          stub_request(:get, "http://chunky.bacon/my_objects/1").to_return(:body => object)
          response = @service.show(:my_object, 1)
          response.should == {"id" => 1, "name" => "first"}
        end
      end
    end
  end
end