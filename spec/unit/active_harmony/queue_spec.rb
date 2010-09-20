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
        @queue.queue_pull(@bacon, '123')
        last_item = QueueItem.last
        last_item.kind.should == 'pull'
        last_item.object_type.should == 'Bacon'
        last_item.object_remote_id.should == '123'
        last_item.state.should == 'new'
      end
    end
  end
end