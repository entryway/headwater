module ApplicationHelper
  def story_state_select(form)
    form.select(:current_state,
             options_for_select(Story::STATES,
                                form.object.current_state))
  end
  
  def format_text(text)
    text = h(text).gsub(/(https?:\/\/(www\.)?([^\s\/]+)([^\s]*))/, '<a href="\1">\3</a>')
    text.gsub!(/\n/, '<br />')
    text.html_safe
  end
end
