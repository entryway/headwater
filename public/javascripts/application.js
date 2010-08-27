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
	$("#status .project_name").css({cursor: 'pointer'}).toggle(function() {
		$("#project_switcher").show();
	}, function() {
		$("#project_switcher").hide();
	});
});