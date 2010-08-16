class ProjectsController < ApplicationController
  helper_method :viewing?
  
  before_filter do
    @projects = Project.all
  end
  
  def index
    respond_to do |wants|
      wants.html
      wants.json {
        render :json => @projects.to_json(:methods => :id_string)
      }
    end
  end
  
  def show
    @project = Project.find(params[:id])
    respond_to do |wants|
      wants.html { redirect_to project_stories_path(params[:id]) }
      wants.json { render :json => @project.to_json(:methods => :id_string) }
    end
    
  end
  
  protected
  
  def viewing?(project)
    @project == project
  end
end