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
}

TimeTracker.update = function(first_time) {
  if (first_time) {$("#time_tracker").css("opacity", 0)};
  $.getScript(TimeTracker.path, function() {
		if (first_time) {
			$("#time_tracker").animate({opacity: 1})
		};
  });
  setTimeout(function() {
    TimeTracker.update()
  }, 30000)
}