class DashboardsController < ApplicationController
  layout "dashboard"
  
  def show
    @projects = Project.all
  end
end