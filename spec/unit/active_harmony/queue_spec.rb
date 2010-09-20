require "spec_helper"

class Bacon
  include Mongoid::Document
end

module ActiveHarmony
  describe Queue do
    before do
      @queue = Queue.instance
      @bacon = Bacon.create
    end
    
    before :each do
      QueueItem.delete_all
    end
    
    describe '#queue_push' do
      it 'should create queue item for push' do
        @queue.queue_push(@bacon)
        last_item = QueueItem.last
        last_item.kind.should == 'push'
        last_item.object_type.should == 'Bacon'
        last_item.object_local_id.should == @bacon.id.to_s
        last_item.object_remote_id.should be_nil
        last_item.state.should == 'new'
      end
    end
    
    describe '#queue_pull' do
      it 'should create queue item for pull' do
        @queue.queue_pull(Bacon, '123')
        last_item = QueueItem.last
        last_item.kind.should == 'pull'
        last_item.object_type.should == 'Bacon'
        last_item.object_remote_id.should == '123'
        last_item.state.should == 'new'
      end
    end
    
    describe '#run' do
      it 'should queued items to process' do        
        items = (1..5).collect do
          item = QueueItem.new(:state => 'new')
          item.expects(:process_item)
          item
        end
        @queue.expects(:queued_items).returns(items)
        @queue.run
      end
    end
    
    describe '#queued_items' do
      it 'should return all items with state new' do
        item_with_no_state = QueueItem.create(:state => nil)
        item_with_new_state = QueueItem.create(:state => 'new')
        queued_items = QueueItem.where(:state => "new").to_a
        @queue.queued_items.to_a.should == queued_items
      end
    end
  end
end