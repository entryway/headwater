# encoding: utf-8

task :sync => :environment do
  threads = []
  locked = false  
  
  puts "----> Starting synchronization"

  pull_thread = Thread.new do
    while true do
      STDOUT.puts "‹Thread/Pull› Starting\n"
      locked = true
      Project.synchronizer.pull_collection
      Project.all.each do |project|
        begin
          STDOUT.puts "‹Thread/Pull› Pulling project #{project.name}\n"
          Story.synchronizer.set_context :projects, project._remote_id
          Story.synchronizer.pull_collection
        rescue Exception => e
          STDOUT.puts "‹Thread/Pull› FAILED\n"
          STDOUT.puts "---------------------"
          STDOUT.puts e.message
          STDOUT.puts e.backtrace.join('\n')
          STDOUT.puts "---------------------"
        end
      end
      STDOUT.puts "‹Thread/Pull› Finished\n"
      locked = false
      sleep 60
    end
  end

  push_thread = Thread.new do
    while true do
      if locked
        STDOUT.puts "‹Thread/Push› Waiting for unlock\n"
      else
        STDOUT.puts "‹Thread/Push› Starting\n"

        @queue = Synchronizer::Queue.instance

        if @queue.should_run?
          STDOUT.puts "‹Thread/Push› Running queue\n"
          @queue.run
          STDOUT.puts "‹Thread/Push› Finished\n"
        else
          STDOUT.puts "‹Thread/Push› Skipping\n"
        end
      end

      sleep 5
    end
  end

  STDOUT.puts "Joining pull thread ...\n"
  pull_thread.join
  sleep 1
  STDOUT.puts "Joining push thread ...\n"
  push_thread.join
end