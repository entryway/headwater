require "spec_helper"

describe Synchronizable do

  class MyClass
    include Mongoid::Document
    include Synchronizable
    synchronizes_through Synchronizer::ServiceSynchronizer
    field :foo
  end
  
  describe ".synchronizable_fields" do
    it "should be an empty array" do
      MyClass.synchronizable_fields.should == []
    end
  end
  
  describe ".synchronize_fields" do
    it "should save synchronizable fields from array" do
      MyClass.synchronizable_fields = []
      MyClass.synchronize_fields [:first_field, :second_field]
      MyClass.synchronizable_fields.should == [:first_field, :second_field]
    end
    
    it "should save synchronizable fields from arguments" do
      MyClass.synchronizable_fields = []
      MyClass.synchronize_fields :first_field, :second_field
      MyClass.synchronizable_fields.should == [:first_field, :second_field]
    end
  end
  
  describe "#synchronizable_fields" do
    before :each do
      MyClass.synchronizable_fields = [:first_field, :second_field]
    end
    
    it "should return array of synchronizable fields" do
      my_object = MyClass.new
      my_object.synchronizable_fields.should == [:first_field, :second_field]
    end
  end

  describe "#push" do
    context "queued" do
      it "should create queue item" do
        my_object = MyClass.new
        my_object.foo = "bar"
        my_object.save
        my_object.push
        queue_item = Synchronizer::QueueItem.last
        queue_item.type.should == "push"
        queue_item.state.should == "new"
        queue_item.result.should == nil
        queue_item.object_type.should == "MyClass"
        queue_item.object_remote_id.should == nil
        queue_item.object_local_id.to_s.should == my_object.id.to_s
      end
    end
    
    context "instant" do
      it "should trigger an instant push" do
        my_object = MyClass.new
        my_object.foo = "bar"
        my_object.synchronizer.expects(:push_object).with(my_object)
        my_object.push(true)
      end
    end
  end
  
end