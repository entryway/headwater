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
		TimeTracker.update(false);
	});
	$(document).bind('story-deselected', function(){
	  TimeTracker.update(false);
	})
	$("#time_tracker .clock a.toggle.create").live('click', function(){
	  var note = prompt('Description:');
	  var data = {
	    'time_entry[note]': note,
	    'start': true
	  }
	  $.ajax({
	    url: $(this).attr('href'),
	    type: 'post',
	    dataType: 'script',
	    data: data
	  })
	  return false;
	})
	$("#time_tracker .clock a.toggle").live('click', function(){
	  if($(this).hasClass("create")) {
	    return false;
	  }
    $.ajax({
      type: 'get',
      url: $(this).attr('href'),
      dataType: 'script',
      data: {story_id: $(Story.selected_story).attr('data-id')}
    });
    return false;
	});
	$("#time_tracker a.update").live('click', function(){
	  if(!Story.selected_story)
	  {
      return false;
	  };
	  var data = {
	    _method: 'put',
      'time_entry[story_id]': $(Story.selected_story).attr('data-id')
	  };

    $.ajax({
      type: 'post',
      url: $(this).attr('href'),
      dataType: 'script',
      data: data
    })

    return false;
	})
}

TimeTracker.update = function(first_time) {
  var story = Story.selected_story;
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
			if(story)
			{
			  $("#time_tracker a.update").show();
			} else {
			  $("#time_tracker a.update").hide();
			}
		}
	})
  setTimeout(function() {
    TimeTracker.update()
  }, 60000)
}