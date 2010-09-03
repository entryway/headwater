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
};

DashboardProject = function(element){
  var self = this;
  self.element = element;
  $(self.element).find('input.toggle_project').click(function(){
    if($(this).hasClass("expanded")) {
      $(this).removeClass("expanded");
    } else {
      $(this).addClass("expanded");
    };
    $(self.element).find('ul.dashboard_stories').toggle();
  });
}