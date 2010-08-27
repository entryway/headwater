jQuery(function($){
  $(document).ready(function() {
    Story.setup()
		// StoryInspector.setup()
    StoryFilter.setup()
  });
});

var Story = {
  setup: function() {
    $("li.story").live('click', function() {
      Story.select(this)
			Story.loadSelected();
    });
  },
  
  select: function(story) {
    $("li.story").removeClass("selected")
    $(story).addClass("selected")
    $("#inspector").removeClass("hidden")
		// $("#inspector").animate({opacity: 0});
    $("body").addClass("with_inspector")
		Story.selected_story = story;
		$(document).trigger('story-selected');
  },

	deselect: function() {
		$("li.story").removeClass("selected")
		$(document).trigger('story-deselected')
	},

	loadSelected: function() {
		var path = $(Story.selected_story).attr("data-path")
		$("#inspector").contents().animate({opacity: 0}, 150);
    $.get(path, function() {
    	$("#inspector").contents().css({opacity: 0}).animate({opacity: 1}, 300);
    });
	}
}

var StoryInspector = function(element) {
	this.element = element;
	element.data('inspector', this);
	this.setup();
};

StoryInspector.prototype.setup = function() {
	var self = this;
	$(self.element).find(".view a.edit").click(function() {
		self.edit(this);
		return false;
	});
	$(self.element).find(".edit a.cancel").click(function() {
		self.cancel(this);
		return false;
	});
	$(self.element).find(".edit a.save").click(function() {
		self.save(this);
		return false;
	});
	$(self.element).find('a.story_action').click(function() {
		self.changeState(this);
		return false;
	})
	$(document).bind('story-deselected', function() {
		$("#inspector").contents().remove();
	});
}

StoryInspector.prototype.edit = function(element) {
	var self = this;
	self.element.find('div.view').addClass('hidden');
	self.element.find('div.edit').removeClass('hidden');
	var save_span = $(self.element).find('div.edit a.save span');
	save_span.text(save_span.data('originalText'));
	var action_buttons = self.element.find('.story_action_buttons');
	// var originalHeight = action_buttons.height();
	// action_buttons.data('originalHeight', originalHeight);
	// action_buttons.animate({opacity: 0, height: 0});
	// .animate({opacity: 0}).slideUp();
	action_buttons.animate({opacity: 0}, 300);
	action_buttons.slideUp(300);
	action_buttons.dequeue();
};

StoryInspector.prototype.cancel = function(element) {
	var self = this;
	self.element.find('div.view').removeClass('hidden');
	self.element.find('div.edit').addClass('hidden');
	var action_buttons = self.element.find('.story_action_buttons');
	action_buttons.animate({opacity: 1}, 300);
	action_buttons.slideDown(300);
	action_buttons.dequeue();
};

StoryInspector.prototype.save = function(trigger) {
	var self = this;
	var form = self.element.find("form.story");
	var path = form.attr('action');
	var data = form.serialize();
	var trigger_span = $(trigger).find('span');
	$(trigger_span).data('originalText', $(trigger_span).text());
	$(trigger_span).text('Saving ...');
	$(trigger).addClass("disabled");
	$.ajax({
		type: 'POST',
		url: path,
		data: data,
		complete: function(response) {
			$(trigger).removeClass("disabled");
			self.cancel();
		},
		dataType: 'script'
	});
};

StoryInspector.prototype.changeState = function(trigger) {
	var self = this;
	var state = $(trigger).attr('data-state');
	var path = self.element.find('form.story').attr('action');
	
	var data = {
		"_method": "put",
		"story[state]": state
	};
	
	$.ajax({
		url: path,
		type: 'POST',
		data: data,
		dataType: 'script'
	});
	
}

var StoryFilter = {
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