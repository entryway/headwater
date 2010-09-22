# encoding: utf-8

namespace :sync do
  task :pull => :environment do
    HeadwaterSynchronization.pull
  end
  
  task :push => :environment do
    ActiveHarmony::Queue.instance.run
  end
end