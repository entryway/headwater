require "spec_helper"

class MyClass
  include Mongoid::Document
  include ActiveHarmony::Synchronizable::Core
  field :foo
end

module ActiveHarmony
  module Synchronizable
    describe Core do
      describe "#push" do
        context "queued" do
          it "should create queue item" do
            my_object = MyClass.new
            my_object.foo = "bar"
            my_object.save
            my_object.push
            queue_item = ActiveHarmony::QueueItem.last
            queue_item.kind.should == "push"
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
  end
end

