class ProjectsController < ApplicationController
  before_filter do
    @projects = Project.all
  end
  
  def index
  end
  
  def show
    redirect_to project_stories_path(params[:id])
  end
end