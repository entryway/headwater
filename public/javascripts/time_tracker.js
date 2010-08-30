$(document).ready(function() {
  TimeTracker.setup();
});

var TimeTracker = function() {

};

TimeTracker.setup = function() {
  var time_tracker = $("#time_tracker")
  if(time_tracker.length > 0) {
    time_tracker.show();
    TimeTracker.path = time_tracker.attr('data-path');
    TimeTracker.update(true)
  }
	$(document).bind('story-selected', function() {
		TimeTracker.update(false, Story.selected_story);
	})
}

TimeTracker.update = function(first_time, story) {
  if (first_time) {$("#time_tracker").css("opacity", 0)};
	var data = {cache: Math.random()};
	if (story) {
		data['story_id'] = $(story).attr('data-id');
	};
	$.ajax({
		url: TimeTracker.path,
		dataType: 'script',
		data: data,
		success: function() {
			if (first_time) {
				$("#time_tracker").animate({opacity: 1})
			};
		}
	})
  setTimeout(function() {
    TimeTracker.update()
  }, 60000)
}