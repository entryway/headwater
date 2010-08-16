// ************************************************************
// View.List

var View = {}
View.List = function() {
  this.items = []
  this.html_classes = []
  this.addItem = function(options) {
    this.items.push(options)
  };
  this.render = function() {
    var ul = $("<ul />");
    $.each(this.html_classes, function(i, klass) {
      ul.addClass(klass);
    })
    $.each(this.items, function(i, item) {
      ul.append(item.render())
    })
    this.element = ul;
    return ul;
  };
  this.addClass = function(klass) {
    this.html_classes.push(klass)
  }
  this.setActiveAtIndex = function(index) {
    $(this.element).find('li').removeClass('active')
    $(this.element.find('li')[index]).addClass('active')
  }
};

View.ListItem = function() {
  this.html_classes = []
  this.render = function() {
    var li = $("<li />");
    $.each(this.html_classes, function(i, klass) {
      li.addClass(klass);
    })
    if (this.link) {
      var a = $("<a />");
      a.attr('href', this.link);
      a.text(this.text);
      a.appendTo(li);
    } else {
      li.text(this.text);
    }
    return li;
  }
  this.addClass = function(klass) {
    this.html_classes.push(klass)
  }
}

View.Story = function() {
  this.story = null
  this.render = function() {
    var li = $("<li />");
    // li.text(this.story.name)
    li.addClass("story")
    li.addClass(this.story.state)
    var icon = $("<div />").addClass("fl icon");
    $("<img />").attr('src', '/images/'+this.story.story_type+'.png').appendTo(icon)
    icon.appendTo(li)
    var desc = $("<div />").addClass("fl").text(this.story.name)
    li.append(desc)
    return li;
  }

}

// ************************************************************
// Application

var app = $.sammy(function() { with(this) {

  var projects = []
  var projects_view = null
  var project = null
  var stories = []
  var stories_view = null

  // Event: Projects are loaded
  this.bind('projects-loaded', function(context) {
    projects_view = new View.List()
    projects_view.addClass('simple navigation')
    $.each(projects, function(i, project) {
      var item = new View.ListItem()
      item.text = project.project.name
      item.link = '#/projects/'+project.project.id_string
      projects_view.addItem(item);
    })
    $("#sidebar").children().remove()
    $("#sidebar").append(projects_view.render())
  })

  // Event: Single project is selected
  this.bind('project-selected', function() {
    $("#document").startLoading();
  });
  
  this.bind('stories-loaded', function() {
    $("#document").finishLoading();
    stories_view = new View.List();
    stories_view.addClass('stories')
    $.each(stories, function(i, story) {
      var item = new View.Story()
      item.story = story.story
      stories_view.addItem(item);
    })
    $("#document").append(stories_view.render())
  })

  // Event: Single project is loaded
  this.bind('project-loaded', function(context) {
    $("#document").finishLoading();
    $("#document").html('')
    var content = $("<div />").addClass("content")
    var title = $("<h3 />").text(project.project.name)
    $("#document").append(content.append(title))
    var index = $.index(project, projects)
    projects_view.setActiveAtIndex(index)
    // Load stories
    $.ajax({
      url: '/projects/' + project.project.id_string + '/stories',
      dataType: 'json',
      success: function(stories) {
        app.stories = stories
        $("#document").startLoading();
        app.trigger('stories-loaded')
      }
    })
  })

  // Path: Project/index
  this.get('#/', function() {
  });
    
  // Path: Project/show
  this.get('#/projects/:id', function(context) {
    this.trigger('project-selected')
    var id = this.params['id'];
    $.ajax({
      url: '/projects/'+id,
      dataType: 'json',
      success: function(project) {
        app.project = project
        app.trigger('project-loaded')
      }
    })
  });
  
  this.bind('run', function(context) {
    $.ajax({
      url: '/projects',
      dataType: 'json',
      success: function(projects) {
        app.projects = projects
        app.trigger('projects-loaded')
      }
    })
  })

}});

$(document).ready(function() {
  app.run()
});