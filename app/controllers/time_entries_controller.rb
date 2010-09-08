class TimeEntriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id]) if params[:project_id]
  end
  
  def index
    @entries = TimeEntry.archived
    @entries = @entries.group_by { |e| e.story.project }
  end
  
  def new
    @story = Story.find(params[:story_id])
    @entry = TimeEntry.new(:story => @story)
  end
  
  def create
    story_id = params[:time_entry].delete(:story_id)
    story = Story.find(story_id) if story_id
    @time_entry = TimeEntry.new
    @time_entry.user = current_user
    @time_entry.story = story
    @time_entry.date = Date.today
    @time_entry.update_attributes(params[:time_entry])
    if params[:start]
      @time_entry.start
    end
    
    respond_to do |wants|
      wants.html { redirect_to story.project }
      wants.js { render :action => :show }
    end
  end
  
  def update
    @time_entry = TimeEntry.find(params[:id])
    @time_entry.update_attributes(params[:time_entry])
    respond_to do |wants|
      wants.html { redirect_to story.project }
      wants.js { render :action => :show }
    end
  end
  
  def current
    @time_entry = TimeEntry.where(:is_running => true, :user_id => current_user.id).first
    
    set_current
    
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
    @time_entry.push
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
  
  protected
  
  def set_current
    if params[:story_id] && (!@time_entry || !@time_entry.is_running)
      story = Story.find(params[:story_id])
      @time_entry = TimeEntry.current_for_story_and_user(story, current_user)
    end
  end
end