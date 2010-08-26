class StoriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    states = ['done', 'current', 'upcoming']
    
    @stories = Story.where(:project_id => @project._remote_id, :state.in => states, :is_archived => false).
                     order_by(:updated_at.desc).
                     group_by(&:state)

    @done = @stories['done']
    @current = @stories['current']
    @upcoming = @stories['upcoming']
  end
  
  def show
    @story = Story.find(params[:id])
    @time_entries = @story.archived_time_entries
    @time_entry = TimeEntry.current_for_story_and_user(@story, current_user)
  end
  
  def update
    @story = Story.find(params[:id])
    state = params[:story].delete(:state)
    if state == "archived"
      @story.is_archived = true
    elsif state
      @story.state = state
    end
    @story.update_attributes(params[:story])
    @story.push
    respond_to do |wants|
      wants.html { redirect_to project_stories_path(@project) }
      wants.js
    end
  end
  
  def new
    @story = Story.new(:project_id => @project._remote_id)
  end
  
  def create
    @story = Story.new(:project_id => @project._remote_id)
    @story.attributes=(params[:story])
    @story.save
    @story.push # FIXME
    respond_to do |wants|
      wants.html { redirect_to project_stories_path(@project) }
    end
  end
  
  def edit
    @story = Story.find(params[:id])
  end
end