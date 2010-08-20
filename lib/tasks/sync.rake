# encoding: utf-8

task :sync => :environment do
  threads = []
  locked = false  

  pull_thread = Thread.new do
    while true do
      puts "‹Thread/Pull› Starting\n"
      locked = true
      Project.synchronizer.pull_collection
      Project.all.each do |project|
        # puts "‹Thread/Pull› Pulling project #{project.name}\n"
        Story.synchronizer.set_context :projects, project._remote_id
        Story.synchronizer.pull_collection
      end
      puts "‹Thread/Pull› Finished\n"
      locked = false
      sleep 20
    end
  end

  push_thread = Thread.new do
    while true do
      if locked
        puts "‹Thread/Push› Waiting for unlock\n"
      else
        puts "‹Thread/Push› Starting\n"

        @queue = Synchronizer::Queue.instance

        if @queue.should_run?
          puts "‹Thread/Push› Running queue\n"
          @queue.run
          puts "‹Thread/Push› Finished\n"
        else
          puts "‹Thread/Push› Skipping\n"
        end
      end

      sleep 5
    end
  end

  puts "Joining pull thread ...\n"
  pull_thread.join
  sleep 1
  puts "Joining push thread ...\n"
  push_thread.join
end