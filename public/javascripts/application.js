$(document).ready(function() {
	$(document).ajaxStart(function() {
		$("body").addClass("loading");
	});
	$(document).ajaxComplete(function() {
		$("body").removeClass("loading");
	})
});