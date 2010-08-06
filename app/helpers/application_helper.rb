module ApplicationHelper
  def story_state_select(form)
    form.select(:current_state,
             options_for_select(Story::STATES,
                                form.object.current_state))
  end
end
