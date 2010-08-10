require "spec_helper"

describe "Fellow views projects", :type => "integration" do
  before do
    Project.make
  end
  
  it "views projects" do
    visit '/projects'
    page.should have_content "Chunky Bacon Project"
  end
end