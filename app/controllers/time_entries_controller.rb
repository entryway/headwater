class TimeEntriesController < ProjectsController
  def new
    @story = Story.find(params[:story_id])
    @entry = TimeEntry.new(:story => @story)
  end
  
  def create
    story_id = params[:time_entry].delete(:story_id)
    story = Story.find(story_id)
    @entry = TimeEntry.new(params[:time_entry])
    if story
      story.time_entries << @entry
      story.save
    end
    @entry.save
    redirect_to story.project
  end
end