class StoriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    params[:archived] ||= 0
    params[:done] ||= 1
    params[:current] ||= 1
    params[:upcoming] ||= 1
    
    states = []
    
    if params[:archived].to_i == 1
      states << 'archived'
    end
    if params[:done].to_i == 1
      states << 'done'
    end
    if params[:current].to_i == 1
      states << 'current'
    end
    if params[:upcoming].to_i == 1
      states << 'upcoming'
    end
    
    @stories = Story.where(:project_id => @project._remote_id, :state.in => states).
                     order_by(:current_state.desc, :updated_at.desc).
                     group_by(&:state)

    @done = @stories['done']
    @current = @stories['current']
    @upcoming = @stories['upcoming']
  end
  
  def show
    
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
end