class StoriesController < ProjectsController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    states = ['done', 'current', 'upcoming', 'new']
    
    @stories = @project.stories.where(:state.in => states, :is_archived => false).
                     group_by(&:state)

    @done = @stories['done']
    @current = @stories['current']
    @upcoming = @stories['upcoming']
    @new = @stories['new']
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
    @story.attributes = params[:story]
    @changes = @story.changes
    @story.save
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
  
  def move
    story = Story.find(params[:id])
    
    id_before = params[:id_before]
    id_after = params[:id_after]
    
    story_before = id_before ? Story.find(id_before) : nil
    story_after = id_after ? Story.find(id_after) : nil
    
    if story_before && story_after
      average_order = (story_before._collection_order.to_f + story_after._collection_order.to_f) / 2.0
      story._collection_order = average_order
      move = 'after'
      target = story_before._remote_id
    elsif story_before
      story._collection_order = story_before._collection_order + 1
      move = 'after'
      target = story_before._remote_id
    elsif story_after
      story._collection_order = story_after._collection_order.to_f - 1
      move = 'before'
      target = story_after._remote_id
    end
    
    path = "/projects/#{story.project._remote_id}/stories/#{story._remote_id}/moves?move[move]=#{move}&move[target]=#{target}"
    url = story.synchronizer.service.generate_url(path)
    story.synchronizer.service.retrieve(url, :post)
    
    story.save
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
  
  def destroy
    @story = Story.find(params[:id])
    @story.delete
    respond_to do |wants|
      wants.html { redirect_to @story.project }
      wants.js { render :nothing => true }
    end
  end
end