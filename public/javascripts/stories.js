jQuery(function($){
  $(document).ready(function() {
    Story.setup()
  });
  $(document).ajaxComplete(function() {
    Story.setup()
  });
});

Story = {
  setup: function() {
    $("li.story").each(function() {
      Story.recognize(this)
    })
  },
  recognize: function(element) {
    var story = $(element)
    story.find("a.change-state").live('click', function() {
      var path = $(this).attr('href')
      var data = {"_method" : "put", 
                  "story[state]" : $(this).attr('data-state')}
      $.post(path, data, function(){}, "script")
      
      return false;
    });
    story.find("input.message").mouseup(function(e) {
      e.preventDefault();
    });
    story.find("input.message").focus(function() {
      this.select();
    });
  }
}