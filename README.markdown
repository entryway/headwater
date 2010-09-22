# Headwater

## What is Headwater

Headwater looks like a project manager, but in fact it does much less.

Headwater takes all your data from [Pivotal Tracker](http://pivotaltracker.com), lets you edit it and do really cool stuff like time tracking, viewing dashboard with data from your projects and your time tracking, and nothing more. But the mentioned works perfectly and it's super useful.

![Headwater Dashboard](https://github.com/entryway/headwater/raw/master/doc/headwater_dashboard.png)

When you make changes, Headwater synchronizes them back to Pivotal Tracker, so you can use the both tools.

Headwater has some basic time tracking features, but if you want some more sophisticated reporting, we added support for synchronizing with [Harvest](http://harvestapp.com). 

You can use Headwater as a project manager on its own, or you can synchronize with other services, it's up to you.

## It's open source

It's free and open source. You can clone the source right now, setup some things and you're good to go.

## So how do I get it running

Headwater is a Rails app. So you need server and everything. 

You should use Ruby 1.8.7 and Rails 3. (1.8.7 because there are some bugs in Rails for 1.9.2. Sorry.)

### MongoDB

First, you need MongoDB. If you're on Mac and you're using Homebrew, just do this:

    homebrew install mongodb

If you're not or Mac or are not using Homebrew, well, help yourself and if you're feeling open-source, fork this file and send us a pull request.

### Cloning the source

Clone the source:

    git clone git://github.com/entryway/headwater.git

Don't forget to install the gems:

    gem install bundler
    bundle install

### Configuration

**Don't** setup your database in `config/mongoid.yml`. It just works.

What you have to setup is your Pivotal Tracker token. Unless you want to use it without Pivotal Tracker.

Open `config/headwater.rb` and just change the values.

    HW_PIVOTAL_TRACKER_URL = "http://www.pivotaltracker.com/services/v3"
    HW_PIVOTAL_TRACKER_API_KEY = "cocakaszetubudeibanejakablbost"
    HW_HARVEST_SUBDOMAIN = "mojaskvelafirma"

    HW_AUTO_PUSH = true

Let me explain:

  * `HW_PIVOTAL_TRACKER_URL`: Don't change this
  * `HW_PIVOTAL_TRACKER_API_KEY`: Your Pivotal Tracker API key
  * `HW_HARVEST_SUBDOMAIN`: Your Harvest subdomain. Just remove that line if you don't use Harvest.
  
Have you noticed something weird? There's no setup of Harvest credentials. And there's a reason for that. Headwater supports multiple users and each user can have their own account for Harvest. Makes sense now?

### Synchronize

Do initial synchronization with Pivotal Tracker:

    rake sync:pull
    
If you want to know more about synchronization, and how it works, check out document named (surprise, surprise) **Synchronization**. 

### Start the server

    rails s
    
Now navigate to `localhost:3000`. If it's not working, report an issue, or send me an email. 

Have fun.