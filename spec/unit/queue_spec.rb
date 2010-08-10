require "spec_helper"

module Synchronizer
  describe Queue do
    
  end
  
  describe QueueItem do
    class ::MyClass
      include Mongoid::Document
      include Synchronizable
      synchronizes_through Synchronizer::ServiceSynchronizer
      field :foo
      synchronize_fields :foo
    end

    let(:queue) { Synchronizer::Queue.instance }
    
    context "type push" do
      describe "#process_item" do
        it "should tell synchronizer to push object" do
          my_object = MyClass.new
          my_object.foo = "bar"
          my_object.save
          queue.queue_push(my_object)
          item = QueueItem.last
          item.object_type.should == "MyClass"
          my_object.synchronizer.expects(:push_object).with(my_object)
          item.process_item
        end
      end
    end
    
    context "type pull" do
      describe "#process_item" do
         it "should tell synchronizer to pull object" do
            queue.queue_pull('MyClass', 123)
            item = QueueItem.last
            item.object_type.should == "MyClass"
            item.type.should == "pull"
            MyClass.synchronizer.expects(:pull_object).with('123')
            item.process_item
          end
      end
    end
  end
end