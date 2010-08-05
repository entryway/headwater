class ProjectsController < ApplicationController
  helper_method :viewing?
  
  before_filter do
    @projects = Project.all
  end
  
  def index
  end
  
  def show
    redirect_to project_stories_path(params[:id])
  end
  
  protected
  
  def viewing?(project)
    @project == project
  end
end