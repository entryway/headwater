class StoriesController < ApplicationController
  before_filter do
    @project = Project.find(params[:project_id])
  end
  
  def index
    
  end
end