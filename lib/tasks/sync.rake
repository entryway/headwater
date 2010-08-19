task :sync => :environment do
  while true do
    @queue = Synchronizer::Queue.instance
    
    if @queue.should_run?
      puts "Running queue ..."
      @queue.run
    else
      puts "(queue is empty)"
    end
    
    puts "(waiting)"
    
    sleep 1
  end
end

task :pull => :environment do
  Project.synchronizer.pull_collection

  Project.all.each do |project|
    Story.synchronizer.set_context :projects, project._remote_id
      Story.synchronizer.pull_collection
  end
end