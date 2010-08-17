jQuery(function($){
  $(document).ready(function() {
    Story.setup()
    Story.setup_once()
    StoryFilter.setup()
  });
  $(document).ajaxStart(function() {
    $("body").addClass("loading")
  })
  $(document).ajaxComplete(function() {
    Story.setup()
    $("body").removeClass("loading")
  });
});

Story = {
  setup: function() {
    $("li.story").each(function() {
      Story.recognize(this)
    })
  },
  setup_once: function() {
    $("li.story").live('click', function() {
      Story.select(this)
    });
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
  },
  
  select: function(story) {
    $("body").addClass("loading")
    $("li.story").removeClass("selected")
    $(story).addClass("selected")
    $("#inspector").removeClass("hidden")
    $("body").addClass("with_inspector")
    var path = $(story).attr("data-path")
    $.get(path)
  }
}

StoryFilter = {
  state_filter: {},
  setup: function() {
    this.state_filter = {
      done: 0,
      current: 1,
      upcoming: 1
    };
    this.type_filter = {
      feature: 1,
      chore: 1,
      bug: 1
    }
    this.update()
    $("a.filter").click(this.filter)
  },
  
  update: function() {
    $.each(this.state_filter, function(state, value) {
      if (value == 1) {
        $("#filter a.filter[data-state="+state+"]").addClass("active")
      } else {
        $("#filter a.filter[data-state="+state+"]").removeClass("active")
      };
    })
    
    $.each(this.type_filter, function(state, value) {
      if (value == 1) {
        $("#type_filter a.filter[data-type="+state+"]").addClass("active")
      } else {
        $("#type_filter a.filter[data-type="+state+"]").removeClass("active")
      };
    })
    
    $("ul.stories li").each(function(i, o) {
      var state = $(o).attr('data-state')
      var type = $(o).attr('data-type')
      if (StoryFilter.state_filter[state] == 1 && StoryFilter.type_filter[type] == 1) {
        $(o).show();
      } else {
        $(o).hide()
      }
    })
  },
  
  filter: function() {
    // State filter
    var type = $(this).attr('data-state')
    var state = 1;
    if(StoryFilter.state_filter[type] == 1) {
      state = 0;
    }
    StoryFilter.state_filter[type] = state;
    // Type filter
    type = $(this).attr('data-type')
    state = 1;
    if(StoryFilter.type_filter[type] == 1) {
      state = 0;
    }
    StoryFilter.type_filter[type] = state;
    StoryFilter.update();
  }
}