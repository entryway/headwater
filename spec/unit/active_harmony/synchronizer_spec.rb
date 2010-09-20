require "spec_helper"

# Bacon.
class Bacon
  include ::Mongoid::Document
  
  include ActiveHarmony::Synchronizable::Core
  include ActiveHarmony::Synchronizable::Mongoid
  
  field :tastyness
end

# Wire up connections
synchronizer = ActiveHarmony::Synchronizer.new
synchronizer.service = ActiveHarmony::Service.new
synchronizer.factory = Bacon
synchronizer.configure do |config|
  config.synchronize :tastyness
end
Bacon.synchronizer = synchronizer

module ActiveHarmony
  describe Synchronizer do
    before :all do
      # References to wired up objects
      @synchronizer = Bacon.synchronizer
      @service      = Bacon.synchronizer.service
    end
    
    before :each do
      Bacon.delete_all
    end
    
    ####################################################
    # Initialization
  
    describe "#factory=" do
      it "should set factory class for finding and creating objects" do
        synchronizer = Synchronizer.new
        factory = Class.new
        synchronizer.factory = factory
        synchronizer.factory.should == factory
      end
      
      it "should set service" do
        synchronizer = Synchronizer.new
        service = Service.new
        synchronizer.service = service
        synchronizer.service.should == service
      end
    end
    
    ###################################################
    # Configuration
    
    describe "#configure" do
      it "should raise an exception when there's no block" do
        synchronizer = Synchronizer.new
        lambda {
          synchronizer.configure
        }.should raise_exception LocalJumpError
      end
      
      it "should yield synchronizer configuration object" do
        synchronizer = Synchronizer.new
        synchronizer.configure do |config|
          config.should == synchronizer.configuration
        end
      end
    end
    
    
    describe "#object_name" do
      it "should return object name for our factory class" do
        # @synchronizer is now reference to Bacon's synchronizer, remember?
        # If not, take a look at before filter on lines 26-27.
        @synchronizer.object_name.should == :bacon
      end
    end
    
    describe "#pull_object" do
      it "should update local object" do
        local_bacon = Bacon.create({
          :_remote_id => 123,
          :tastyness => 'Meh'
        })
        @service.expects(:show).with(:bacon, 123).returns({
          'id' => 123,
          'tastyness' => 'Average'
        })
        @synchronizer.pull_object(123)
        local_bacon.reload
        local_bacon.tastyness.should == 'Average'
      end
      
      it "should create a new local object" do
        # In the Before Block, we're deleting all Bacons.
        Bacon.count.should == 0 # <-- Do you believe me now?
        @service.expects(:show).with(:bacon, 123).returns({
          'id' => 123,
          'tastyness' => 'Average'
        })
        @synchronizer.pull_object(123)
        bacon = Bacon.last
        bacon._remote_id.should == 123
        bacon.tastyness.should == 'Average'
      end
    end
    
    describe "#push_object" do
      before :each do
        @bacon = Bacon.create(:tastyness => "Chunky")
      end
      
      context "remote object exists" do
        before :each do
          @bacon._remote_id = 123
        end
        
        it "should update remote object" do
          @service.expects(:update).with(:bacon, 123, {"tastyness" => "Chunky"})
          @synchronizer.push_object(@bacon)
        end
      end
      
      context "remote object does not exist" do
        before :each do
          @bacon._remote_id = nil
        end
        
        it "should create a new remote object" do
          @service.expects(:update).never
          @service.expects(:create).with(:bacon, {"tastyness" => "Chunky"})
          @synchronizer.push_object(@bacon)
        end
        
        it "should save remote id of newly created remote object" do
          @service.
            expects(:create).
            with(:bacon, {"tastyness" => "Chunky"}).
            returns({"id" => 202, "tastyness" => "Average"})
          @synchronizer.push_object(@bacon)
          @bacon.reload
          @bacon._remote_id.should == 202
          @bacon.tastyness.should == "Average"
        end
      end
    end
    
    describe "#pull_collection" do
      before :each do
        @bacons = [
          Bacon.create(:_remote_id => 1, :tastyness => 'Meh'),
          Bacon.create(:_remote_id => 2, :tastyness => 'Average')
        ]
        
        @service.expects(:list).with(:bacon).returns([
          {'id' => 1, 'tastyness' => 'Super Meh'},
          {'id' => 2, 'tastyness' => 'Super Average'},
          {'id' => 3, 'tastyness' => 'Mmmmmmmmmm'}
        ])
        
        @synchronizer.pull_collection
        @bacons.each { |b| b.reload }
      end
      
      it "should update objects" do
        @bacons[0].tastyness.should == 'Super Meh'
        @bacons[1].tastyness.should == 'Super Average'
      end
    
      it "should create new object" do
        new_bacon = Bacon.last
        new_bacon.tastyness.should == 'Mmmmmmmmmm'
      end
      
      it 'should set order' do
        pending
      end
    end
  end
end