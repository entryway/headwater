class ProjectsController < ApplicationController
  before_filter :authenticate_user!
  
  helper_method :viewing?
  
  layout "project"
  
  before_filter do
    @projects = Project.all
  end
  
  def index
    render :action => 'index', :layout => 'application'
  end
  
  def show
    redirect_to project_stories_path(params[:id])
  end
  
  def edit
    @project = Project.find(params[:id])
    
    respond_to do |wants|
      wants.html
      wants.js
    end
  end
  
  def update
    @project = Project.find(params[:id])
    @project.update_attributes(params[:project])
    respond_to do |wants|
      wants.html { redirect_to @project }
      wants.js { render :text => "$.removeModal();" }
    end
  end
  
  def new
    @project = Project.new
    render :action => 'new', :layout => 'application'
  end
  
  def create
    @project = Project.new(params[:project])
    @project.save
    redirect_to project_path(@project)
  end
  
  protected
  
  def viewing?(project)
    @project == project
  end
end