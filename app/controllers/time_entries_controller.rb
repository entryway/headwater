class TimeEntriesController < ProjectsController
  def index
    @entries = TimeEntry.archived
  end
  
  def new
    @story = Story.find(params[:story_id])
    @entry = TimeEntry.new(:story => @story)
  end
  
  def create
    story_id = params[:time_entry].delete(:story_id)
    story = Story.find(story_id)
    @entry = TimeEntry.new(params[:time_entry])
    if story
      story.time_entries << @entry
      story.save
    end
    @entry.save
    redirect_to story.project
  end
  
  def show
    @time_entry = TimeEntry.find(params[:id])
  end
  
  def start
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.start
    respond_to do |wants|
      wants.json { render :json => @time_entry }
      wants.js { render :action => :show }
    end
  end
  
  def pause
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.pause
    respond_to do |wants|
      wants.json { render :json => @time_entry }
      wants.js { render :action => :show }
    end
  end
  
  def remove
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.destroy
    
    respond_to do |wants|
      wants.js
    end
  end
end