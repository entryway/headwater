// Dashboard

$(document).ready(function(){
  var dashboardElement = $("#dashboard");
  
  if(dashboardElement.length > 0) {
    var dashboard = new Dashboard(dashboardElement);
  };
});

Dashboard = function(element){
  var self = this;
  self.element = element;
  self.projects = [];
  $(self.element).find('div.dashboard_project').each(function(i, el){
    var project = new DashboardProject(el);
    project.dashboard = self;
    self.projects.push(project);
  });
  self.restore();
};

Dashboard.prototype.conserve = function(){
  var self = this;
  var collapsedProjects = [];
  var project = null;
  for(index in self.projects) {
    if(self.projects[index].state == 'collapsed') {
      collapsedProjects.push(index);
    }
  }
  
  $.cookie('dashboard', collapsedProjects.join(','));
};

Dashboard.prototype.restore = function(){
  var self = this;
  var collapsedProjects = $.cookie('dashboard').split(',');
  var project = null;
  for(i in collapsedProjects) {
    project = self.projects[collapsedProjects[i]];
    project.state = 'collapsed';
    project.drawState();
  }
}

DashboardProject = function(element){
  var self = this;
  self.element = element;
  self.triggerElement = $(self.element).find('input.toggle_project');
  self.listElement = $(self.element).find('ul.dashboard_stories');
  self.state = 'expanded';
  $(self.triggerElement).click(function(){
    if(self.state == 'expanded') {
      self.state = 'collapsed';
    } else {
      self.state = 'expanded';
    }
    self.drawState();
    self.dashboard.conserve();
  });
}

DashboardProject.prototype.drawState = function(){
  var self = this;
  if(self.state == 'expanded') {
    $(self.triggerElement).addClass('expanded');
    $(self.listElement).show();
  } else {
    $(self.triggerElement).removeClass('expanded');
    $(self.listElement).hide();
  }
}