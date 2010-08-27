class TimeEntriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
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
    @entry = TimeEntry.new_for_story_and_user(story, current_user)
    @entry = TimeEntry.update_attributes(params[:time_entry])
    redirect_to story.project
  end
  
  def current
    @time_entry = TimeEntry.where(:is_running => true).first
    
    if !@time_entry && params[:story_id]
      story = Story.find(params[:story_id])
      @time_entry = TimeEntry.current_for_story_and_user(story, current_user)
    end
    
    respond_to do |wants|
      wants.js
    end
  end
  
  def show
    @time_entry = TimeEntry.find(params[:id])

    respond_to do |wants|
      wants.html
    end
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