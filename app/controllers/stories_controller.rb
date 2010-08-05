class StoriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    params[:done] ||= 0
    params[:current] ||= 1
    params[:upcoming] ||= 1
    
    states = []
    
    if params[:done].to_i == 1
      states << 'done'
    end
    if params[:current].to_i == 1
      states << 'current'
    end
    if params[:upcoming].to_i == 1
      states << 'upcoming'
    end
    
    @stories = Story.where(:project_id => @project._remote_id,
                           :state.in => states ).group_by(&:state)
    @done = @stories['done']
    @current = @stories['current']
    @upcoming = @stories['upcoming']
  end
end