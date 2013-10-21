/*
 Copyright (C) 2013 Typesafe, Inc <http://typesafe.com>
 */
define(['text!./console.html', 'core/pluginapi', 'css!./console.css'], function(template, api){
  var ko = api.ko;

  var consoleConsole = api.PluginWidget({
    id: 'console-widget',
    template: template
  });

  return api.Plugin({
    id: 'console',
    name: "Inspect",
    icon: "B",
    url: "#console",
    routes: {
      'console': function() { api.setActiveWidget(consoleConsole); }
    },
    widgets: [consoleConsole],
    status: consoleConsole.status
  });
});
