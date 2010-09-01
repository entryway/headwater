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

$.modal = function(html){
  // $("#modal_overlay, #modal_wrapper, #modal").remove();
  $.removeModal();
  var overlay = $("<div />").attr("id", "modal_overlay").appendTo($("body")).addClass("shown");
  overlay.click(function(){
    $.removeModal();
  })
  var wrapper = $("<div />").attr("id", "modal_wrapper");
  var modal = $("<div />").attr("id", "modal").appendTo(wrapper);
  modal.html(html);
  modal.find("form").addClass("ajax");
  wrapper.appendTo($("body"));
}

$.removeModal = function(){
  $("#modal_overlay, #modal_wrapper, #modal").remove();
}