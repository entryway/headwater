require "spec_helper"

module ActiveHarmony
  module Synchronizable
    class MyModel; include ::Mongoid::Document; end
    
    describe Mongoid do
    
      before do
        MyModel.send :include, ActiveHarmony::Synchronizable::Mongoid
        @new_model = MyModel.new
      end
      
      it "should add _remote_id_field" do
        @new_model._remote_id = 1
        @new_model._remote_id.should == 1
      end
      
      it "should add _collection_order field" do
        @new_model._collection_order = 1
        @new_model._collection_order.should == 1
      end
      
    end
  end
end