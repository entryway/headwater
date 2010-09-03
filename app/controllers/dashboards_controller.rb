class DashboardsController < ApplicationController
  layout "dashboard"
  
  before_filter :authenticate_user!
  
  def show
    @projects = Project.all.order_by(:hours_per_week => :desc)
  end
end