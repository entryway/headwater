# Synchronization

## Setup / API keys

Headwater synchronizes with __Pivotal Tracker__ and __Harvest__ time tracker. 

These two services are set up in `config/headwater.rb`. Also, this is where you should change the keys to your own keys. This settings will be moved to configuration YAML file.

Notice, that you don't setup Harvest API key. This is setup per-account in your account settings. If you don't setup your Harvest API key, Harvest synchronization won't work.

## Initial pull

After you have set up everything, it's time to do your initial pull. 

    rake sync:pull
    
Pretty simple, isn't it? This rake task will pull all projects from Pivotal Tracker and pull stories for each. 

Repeat this each time you want changes from remote server.

## Pushing changes

By default, on each requests Headwater checks synchronization queue and tries to synchronize the changes. This can be turned off in `config/headwater.rb` and if decide to do so, then you have to push changes manually:

    rake sync:push
    
# How to make it work

Pushing will work automatically if you don't change anything.

For pulling, setup cron task, that would call `rake cron`. `rake cron` is a shortcut for `rake sync:pull`, but it might do something more in the future.

Call this as often as you need to pull. Each 10 minutes is not weird. Once a day is weird.

This works well with Heroku, but note Heroku supports cron once a day for free and each hour for $3/month.