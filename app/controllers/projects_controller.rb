class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  helper_method :viewing?
  
  before_filter do
    @projects = Project.all
  end
  
  def index
  end
  
  def show
    redirect_to project_stories_path(params[:id])
  end
  
  def edit
    @project = Project.find(params[:id])
  end
  
  def update
    @project = Project.find(params[:id])
    @project.update_attributes(params[:project])
    redirect_to @project
  end
  
  protected
  
  def viewing?(project)
    @project == project
  end
end