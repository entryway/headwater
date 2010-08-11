jQuery(function($){
  var setup = function() {
    Story.setup()
  }
  
  $(document).ready(function() {
    setup()
    StoryFilter.setup()
  });
  $(document).ajaxComplete(function() {
    setup()
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

StoryFilter = {
  filter_data: {},
  setup: function() {
    var filter = {}
    $("ul.stories").each(function(i, el) {
      var type = $(this).attr('data-state');
      if ($(el).hasClass("hidden")) {
        filter[type] = 0;
      } else {
        filter[type] = 1;
      };
    })
    this.filter_data = filter;
    this.update()
    $("#filter a.filter").click(this.filter)
  },
  
  update: function() {
    $.each(this.filter_data, function(state, value) {
      if (value == 1) {
        $("ul.stories[data-state="+state+"]").removeClass("hidden")
        $("#filter a.filter[data-state="+state+"]").addClass("active")
      } else {
        $("ul.stories[data-state="+state+"]").addClass("hidden")
        $("#filter a.filter[data-state="+state+"]").removeClass("active")
      };
    })
  },
  
  filter: function() {
    type = $(this).attr('data-state')
    var state = 1;
    if(StoryFilter.filter_data[type] == 1) {
      state = 0;
    }
    StoryFilter.filter_data[type] = state;
    console.log(StoryFilter.filter_data)
    StoryFilter.update();
  }
}