/*
 Copyright (C) 2013 Typesafe, Inc <http://typesafe.com>
 */
define(['core/model', 'text!./console.html', 'core/pluginapi', 'css!./console.css'], function(model, template, api){
  var ko = api.ko;

  var consoleConsole = api.PluginWidget({
    id: 'console-widget',
    template: template,
    init: function(parameters) {
      this.atmosCompatible = model.snap.app.hasConsole;
    }
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
