require "spec_helper"

describe TimeEntry do
  before :each do
    @time_started = Time.local(2010, 8, 5, 10, 0, 0)
    Timecop.freeze(@time_started)
    @time_entry = TimeEntry.new(:date => "2010-08-05")
  end
  
  context "first run" do
    ## We start a time tracker
    describe "#start" do
      it "should start time tracking" do
        @time_entry.start
        @time_entry.is_running.should == true
        @time_entry.started_at.should == @time_started
        @time_entry.last_started_at.should == @time_started
        @time_entry.length.should == 0
      end
    end
  
    ## Time passes, and we wanna know how long it's been
    describe "#current_length" do
      it "should update the length" do
        @time_entry.start
        @time_entry.is_running.should == true
        
        updated_time = @time_started + 5.minutes
        puts "Updating time to #{updated_time}"
        Timecop.freeze(updated_time)
        @time_entry.current_length.should == 5
      end
    end
  
    ## Then we pause it and we wanna know how long it's been
    describe "#pause" do
      it "should pause it" do
        @time_entry.start
        updated_time = @time_started + 30.minutes
        Timecop.freeze(updated_time)
        @time_entry.current_length.should == 30
        @time_entry.pause
        @time_entry.length.should == 30
        @time_entry.is_running.should == false
      end
    end
  end
  
  context "continue started entry" do
    before :each do
      @time_entry.start
      @updated_time = @time_started + 30.minutes
      Timecop.freeze(@updated_time)
      @time_entry.pause
    end
    
    describe "#current_length" do
      it "should return length for current run" do
        again_updated_time = @updated_time + 60.minutes
        Timecop.freeze(again_updated_time)
        @time_entry.start
        Timecop.freeze(again_updated_time + 5.minutes)
        @time_entry.current_length.should == 5
      end
    end
    
    describe "#length" do
      it "should return length for whole tracking" do
        again_updated_time = @updated_time + 60.minutes
        Timecop.freeze(again_updated_time)
        @time_entry.start
        Timecop.freeze(again_updated_time + 5.minutes)
        @time_entry.pause
        @time_entry.length.should == 35
      end
    end
  end
  
end