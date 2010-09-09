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
    "[##{story._remote_id}] #{story.name}" if story
  end
  
  def git_flow_message(story)
    type = if ['done', 'archived'].include?(story.state)
      "finish"
    else
      "start"
    end
    "git flow feature #{type} #{story.name.gsub(/[\s\-\.]+/, '_').downcase}_#{story._remote_id}"
  end
  
  def estimate_select(form, field = :estimate)
    if form.object.project.point_scale
      options = form.object.project.point_scale.split(',')
    else
      options = []
    end
    options.unshift([])
    form.select(field, options_for_select(options, form.object.send(field).to_s))
  end
  
  def type_select(form, field = :story_type)
    options = Story::TYPES.collect { |type|
      [I18n.t(type), type]
    }
    form.select(field, options_for_select(options, form.object.send(field).to_s))
  end
  
  def state_select(form, field = :current_state)
    options = Story::STATES.collect { |state| 
      [I18n.t(state), state]
    }
    form.select(field, options_for_select(options, form.object.send(field).to_s))
  end
end