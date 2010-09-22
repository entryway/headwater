# Synchronization

## Setup / API keys

Headwater synchronizes with __Pivotal Tracker__ and __Harvest__ time tracker. 

These two services are set up in _config/headwater.rb_. Also, this is where you should change the keys to your own keys. This settings will be moved to configuration YAML file.

Notice, that you don't setup Harvest API key. This is setup per-account in your account settings. If you don't setup your Harvest API key, Harvest synchronization won't work.

## Initial pull

After you have set up everything, it's time to do your initial pull. 

    rake sync:pull
    
Pretty simple, isn't it? This rake task will pull all projects from Pivotal Tracker and pull stories for each. 

## Pushing changes

By default, on each requests Headwater checks synchronization queue and tries to synchronize the changes. This can be turned off in _config/headwater.rb_ and if decide to do so, then you have to push changes manually:

    rake sync:push
    
