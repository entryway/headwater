$(document).ready(function() {
	$(document).ajaxStart(function() {
		$("body").addClass("loading");
	});
	$(document).ajaxComplete(function() {
		$("body").removeClass("loading");
	})
	$("input.select").live('mouseup', function(e) {
		e.preventDefault();
	});
	$("input.select").live('click', function() {
		this.select();
	});
});