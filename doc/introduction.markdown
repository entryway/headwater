# Introducing Headwater

Being a web development company we have many problems with the process, and we trying to make our work as easy as possible.

## Problems & Solutions

1. Project management

We use tool called [Pivotal Tracker](http://pivotaltracker.com). It's free and it's much better than many paid solutions. We use it and we like it. It has some flaws, but there's no need to reinvent the wheel.

2. Time tracking

We use [Harvest](http://harvestapp.com), the time tracker. That's how we track our time and bill the clients. 

3. Source code management

Git and [GitHub](http://github.com), there's probably no better solution.

## Let's integrate

We like all of these tools. But using all of these for simple everyday tasks can be painful.

So we created application called Headwater. This is what it looks like:

![Dashboard](https://github.com/entryway/headwater/raw/master/doc/images/dashboard.png)

First, it takes all your data from Tracker and displays nice Dashboard of what's happening across all projects. You can go to project and see clear overview of what's the next thing to work on. Tracker is cool, but for simple "hey, what should I do next" it can be really hard to use. In Headwater, it's much more intuitive:

![Project](https://github.com/entryway/headwater/raw/master/doc/images/project.png)

Next, it tracks time. Again, we're not trying to replace Harvest, because we like lots of its features, but most of the time we just want to track the time for some task. In Headwater, you just click on the task and then click on the 'play' button. That's it. As soon as you stop the time tracking it appears in your Harvest account.

Since we have all data about projects and how much time was spent - "why not use that data" - we thought. So we added another feature to the dashboard - a feature that takes time tracking data and displays per-project 'progress' for the week. You can set goal hours for a project in your project settings.

Since I mentioned GitHub, let me tell you about another cool feature we developed. It's just a simple text box containing commit message with Tracker task ID. Most of the times your commits are considering some task, and in many cases the commit is solution for a task. So you can just copy a commit message from Headwater and paste it to your Terminal. It saves lots of time.

## Synchronization

You might have noticed that we mention things like 'getting data' or 'synchronizing' a lot. That's possible thanks to our Ruby synchronization library called [Active Harmony](http://github.com/vojto/active_harmony). Thanks to that we can setup new REST service and synchronize our models in 30 minutes.

## Open source

Headwater is open-source and is available now on [GitHub:](http://github.com/entryway/headwater). 