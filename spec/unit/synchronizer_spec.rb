require "spec_helper"
require "synchronizer"
require "service"

module Synchronizer
  describe ServiceSynchronizer do
    before :each do
      @syncer = ServiceSynchronizer.new
      @service = Service::RestService.new
      @service.base_url = "http://chunky.bacon"
    end
  
    describe "#factory=" do
      it "should set factory class for finding and creating objects" do
        factory = Class.new
        @syncer.factory = factory
        @syncer.factory.should == factory
      end
      
      it "should set service" do
        @syncer.service = @service
        @syncer.service.should == @service
      end
    end
    
    describe "#object_name" do
      it "should return object name for our factory class" do
        factory_class = mock('MyObject')
        factory_class.stubs(:object_name).returns("my_object")
        @syncer.factory = factory_class
        @syncer.object_name.should == :my_object
      end
    end
    
    describe "#pull_object" do
      it "should pull remote changes for synchronizable fields to local object" do
        object = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_object>
<id type="integer">123</id>
<name>first</name>
<some_stupid_attribute>bla bla bla</some_stupid_attribute>
</my_object>
EOF
        stub_request(:get, "http://chunky.bacon/my_objects/123").to_return(:body => object)
        # [Local] Factory class for finding/creating objects
        object = mock('object_123')
        object.expects(:name=).with("first").returns(true)
        object.expects(:save).returns(true)
        object.expects(:some_stupid_attribute).never
        object.expects(:contexts).returns({})
        factory_class = mock('MyObject')
        factory_class.stubs(:object_name).returns("my_object")
        factory_class.expects(:with_remote_id).with(123).returns(object)
        factory_class.stubs(:synchronizable_fields).returns([:name])
        @syncer.factory = factory_class
        # [Remote] REST service
        @syncer.service = @service
        # Pull it!
        @syncer.pull_object(123)
      end
      
      it "should create a new local object for remote object" do
        object = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_object>
<id type="integer">123</id>
<name>first</name>
<some_stupid_attribute>bla bla bla</some_stupid_attribute>
</my_object>
EOF
        stub_request(:get, "http://chunky.bacon/my_objects/123").to_return(:body => object)
        # [Local] Factory class for finding/creating objects
        object = mock('object_123')
        object.expects(:name=).with("first")
        object.expects(:save)
        factory_class = mock('MyObject')
        factory_class.stubs(:synchronizable_fields).returns([:name])
        factory_class.stubs(:object_name).returns("my_object")
        factory_class.stubs(:with_remote_id).returns(nil)
        factory_class.expects(:new).returns(object)
        @syncer.factory = factory_class
        # [Remote] REST service
        @syncer.service = @service
        # Pull it!
        @syncer.pull_object(123)
      end
    end
    
    describe "#push_object" do
      before do
        @syncer.service = @service
        @object = mock('object_123')
        @object.stubs(:name).returns("just_another_name")
        @object.stubs(:synchronizable_fields).returns([:name])
        @object.stubs(:contexts).returns({})
        factory_class = mock('MyObject')
        factory_class.stubs(:object_name).returns("my_object")
        @syncer.factory = factory_class
      end
      
      context "remote object exists" do
        before do
          @object.stubs(:_remote_id).returns(123)
        end
        
        it "should update remote object" do
          @service.expects(:update).with(:my_object, 123, {"name" => "just_another_name"})
          @syncer.push_object(@object)
        end
      end
      
      context "remote object does not exist" do
        before do
          @object.stubs(:_remote_id).returns(nil)
        end
        
        it "should create a new remote object" do
          @service.expects(:update).never
          @service.expects(:create).with(:my_object, {"name" => "just_another_name"})
          @syncer.push_object(@object)
        end
        
        it "should save remote id of newly created remote object" do
          @service.expects(:create).with(:my_object, {"name" => "just_another_name"}).
            returns({"id" => 202, "name" => "just_another_name"})
          @object.expects(:_remote_id=)
          @object.stubs(:save)
          @syncer.push_object(@object)
        end
      end
    end
    
    describe "#pull_collection" do
      before do
        @object_1 = mock('object_1')
        @object_1.stubs(:id).returns(1)
        @object_1.stubs(:name).returns("first")
        @object_2 = mock('object_2')
        @object_2.stubs(:id).returns(2)
        @object_2.stubs(:name).returns("second")
        @factory_class = mock('MyObject')
        @factory_class.stubs(:object_name).returns("my_object")
        @factory_class.stubs(:with_remote_id).with(1).returns(@object_1)
        @factory_class.stubs(:with_remote_id).with(2).returns(@object_2)
        @syncer.service = @service
        @syncer.factory = @factory_class
      end
      
      context "without a context" do
        it "should update local objects" do
          collection = <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <my_objects type="array">
    <my_object>
      <id type="integer">1</id>
      <name>updated first</name>
    </my_object>
    <my_object>
      <id type="integer">2</id>
      <name>updated second</name>
    </my_object>
  </my_objects>
  EOF
          stub_request(:get, "http://chunky.bacon/my_objects").to_return(:body => collection)
          @object_1.expects(:name=).with("updated first")
          @object_1.expects(:save)
          @object_2.expects(:name=).with("updated second")
          @object_2.expects(:save)
          @syncer.pull_collection
        end
      
        it "should create local object" do
          collection = <<-EOF
  <?xml version="1.0" encoding="UTF-8"?>
  <my_objects type="array">
    <my_object>
      <id type="integer">3</id>
      <name>new object</name>
    </my_object>
  </my_objects>
  EOF
          stub_request(:get, "http://chunky.bacon/my_objects").to_return(:body => collection)
          @factory_class.stubs(:with_remote_id).with(3).returns(nil)
          object_3 = mock("object_3")
          @factory_class.stubs(:new).returns(object_3)
          object_3.expects(:name=).with("new object")
          object_3.expects(:update_remote_id).with(3)
          object_3.expects(:save)
          @syncer.pull_collection
        end
      end # context: without a context
      
      context "with a context" do
        it "should update local objects" do
          collection = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<my_objects type="array">
  <my_object>
    <id type="integer">1</id>
    <name>updated first</name>
  </my_object>
  <my_object>
    <id type="integer">2</id>
    <name>updated second</name>
  </my_object>
</my_objects>
EOF

          stub_request(:get, "http://chunky.bacon/context_object/801/my_objects").to_return(:body => collection)
          @object_1.expects(:name=).with("updated first")
          @object_1.expects(:save)
          @object_2.expects(:name=).with("updated second")
          @object_2.expects(:save)
          @syncer.set_context(:context_object, 801)
          @syncer.pull_collection
        end
      end # context
    end # describe pull_collection
  end
end