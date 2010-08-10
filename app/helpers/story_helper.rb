module StoryHelper
  def change_state_button(story)
    path = project_story_path(story.project, story)
    attributes = {:class => "change-state"}
    if story.state == "current"
      text = "Finish"
      attributes[:"data-state"] = "done"
    elsif story.state == "upcoming"
      text = "Start"
      attributes[:"data-state"] = "current"
    elsif story.state == "done"
      text = "Archive"
      attributes[:"data-state"] = "archived"
    end
    if story.state != "archived"
      link_to(text, path, attributes)
    end
  end
  
  def commit_message(story)
    update_message = if ['done', 'archived'].include?(story.state)
      "Finished"
    else
      "Progress"
    end
    "[#{update_message}: ##{story._remote_id}] #{story.name}"
  end
end