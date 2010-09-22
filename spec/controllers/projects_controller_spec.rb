require 'spec_helper'

describe ProjectsController do
  before do
    ProjectsController.any_instance.stubs(:authenticate_user!)
  end
  
  describe 'GET /projects/new' do
    it 'should assign a new project to ivar' do
      get :new
      assigns(:project).should be_a(Project)
    end
  end
  
  describe 'POST /projects' do
    it 'should create a new project' do
      post :create, :project => {:name => 'Chunky Bacon'}
      Project.last.should_not be_nil
      Project.last.name.should == 'Chunky Bacon'
      response.should redirect_to project_path(Project.last)
    end
  end
end