$(document).ready(function() {
  TimeTracker.setup();
});

var TimeTracker = function() {

};

TimeTracker.setup = function() {
  $("#time_tracker").show();
  TimeTracker.path = $("#time_tracker").attr('data-path');
  TimeTracker.update()
}

TimeTracker.update = function() {
  $("#time_tracker").css("opacity", 0.5)
  $.getScript(TimeTracker.path, function() {
    $("#time_tracker").css("opacity", 1)
  });
  setTimeout(function() {
    TimeTracker.update()
  }, 30000)
}