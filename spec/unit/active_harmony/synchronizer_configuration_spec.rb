require 'spec_helper'

module ActiveHarmony
  describe SynchronizerConfiguration do
    before :each do
      @config = SynchronizerConfiguration.new
    end
    
    describe '#push' do
      it 'should add a push field to synchronizable fields' do
        @config.push :chunky
        @config.push :bacon
        @config.instance_variable_get(:@synchronizable_fields).should == \
          [{:type => SynchronizerConfiguration::TYPE_PUSH, :field => :chunky},
           {:type => SynchronizerConfiguration::TYPE_PUSH, :field => :bacon}]
      end
    end
    
    describe '#pull' do
      it 'should add a pull field to synchronizable fields' do
        @config.pull :chunky
        @config.pull :bacon
        @config.instance_variable_get(:@synchronizable_fields).should == \
          [{:type => SynchronizerConfiguration::TYPE_PULL, :field => :chunky},
           {:type => SynchronizerConfiguration::TYPE_PULL, :field => :bacon}]
      end
    end
    
    describe '#synchronize' do
      it 'should add field of certain type to synchronizable fields' do
        @config.synchronize :chunky, :type => :chunky_type
        @config.instance_variable_get(:@synchronizable_fields).should == \
          [{:field => :chunky, :type => :chunky_type}]
      end
      
      it 'should add field with no type to synchronizable fields' do
        @config.synchronize :chunky
        @config.instance_variable_get(:@synchronizable_fields).should == \
          [{:field => :chunky, :type => SynchronizerConfiguration::TYPE_ALL}]
      end
    end
    
    describe '#synchronizable_for_push' do
      it 'returns fields for push' do
        @config.push :chunky
        @config.push :bacon
        @config.pull :meh
        @config.synchronizable_for_push.should == [:chunky, :bacon]
      end
    end
    
    describe '#synchronizable_for_pull' do
      it 'returns fields for pull' do
        @config.pull :chunky
        @config.pull :bacon
        @config.push :meh
        @config.synchronizable_for_pull.should == [:chunky, :bacon]
      end
    end
    
    describe '#synchronizable_for_types' do
      it 'returns synchronizables for specified types' do
        @config.synchronize :chunky, :type => :chunky_type
        @config.synchronize :bacon, :type => :bacon_type
        @config.synchronize :meh, :type => :meh_type
        @config.synchronizable_for_types([:chunky_type, :meh_type]).should == \
          [:chunky, :meh]
      end
    end
  end
end