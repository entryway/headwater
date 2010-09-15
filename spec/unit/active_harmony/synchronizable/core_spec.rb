require "spec_helper"

class MyClass
  include Mongoid::Document
  include ActiveHarmony::Synchronizable::Core
  field :foo
end

module ActiveHarmony
  module Synchronizable
    describe Core do

      describe ".synchronizable_fields" do
        context "with no fields" do
          before do
            MyClass.synchronizable_fields = []
          end

          it "should be an empty array" do
            MyClass.synchronizable_fields.should == []
          end
        end

        context "with fields" do
          before do
            MyClass.synchronizable_fields = [{:field => :push_field, :type => :push},
                                             {:field => :pull_field, :type => :pull},
                                             {:field => :all_field, :type => :all}]
          end

          it "should return all fields" do
            MyClass.synchronizable_fields.should == [:push_field, :pull_field, :all_field]
          end

          it "should return fields for push" do
            MyClass.synchronizable_fields(:push).should == [:push_field, :all_field]
          end

          it "should return fields for pull" do
            MyClass.synchronizable_fields(:pull).should == [:pull_field, :all_field]
          end
        end
      end

      describe ".synchronize_fields" do
        before :each do
          MyClass.synchronizable_fields = []
        end

        it "should save synchronizable fields from array" do
          MyClass.synchronize_fields [:first_field, :second_field]
          MyClass.send(:class_variable_get, :@@synchronizable_fields).should == \
            [{:field => :first_field, :type => :all}, {:field => :second_field, :type => :all}]
        end

        it "should save synchronizable fields from arguments" do
          MyClass.synchronize_fields :first_field, :second_field
          MyClass.send(:class_variable_get, :@@synchronizable_fields).should == \
            [{:field => :first_field, :type => :all}, {:field => :second_field, :type => :all}]
        end
      end

      describe ".synchronize_field" do
        before :each do
          MyClass.synchronizable_fields = []
        end

        it "should synchronize general field" do
          MyClass.synchronize_field :some_field
          MyClass.send(:class_variable_get, :@@synchronizable_fields).should == \
            [{:field => :some_field, :type => :all}]
        end

        it "should synchronize push field" do
          MyClass.synchronize_field :some_field => :push
          MyClass.send(:class_variable_get, :@@synchronizable_fields).should == \
            [{:field => :some_field, :type => :push}]
        end

        it "should synchronize pull field" do
          MyClass.synchronize_field :some_field => :pull
          MyClass.send(:class_variable_get, :@@synchronizable_fields).should == \
            [{:field => :some_field, :type => :pull}]
        end
      end

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

