class StoriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    states = ['done', 'current', 'upcoming']
    
    @stories = Story.where(:project_id => @project._remote_id, :state.in => states).
                     order_by(:updated_at.desc).
                     group_by(&:state)

    @done = @stories['done']
    @current = @stories['current']
    @upcoming = @stories['upcoming']
  end
  
  def show
    @story = Story.find(params[:id])
  end
  
  def update
    @story = Story.find(params[:id])
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
end