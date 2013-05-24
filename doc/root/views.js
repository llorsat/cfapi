/*
* Your views here
*/

(function(namespace) {

  var views = namespace.views;
  var models = namespace.models;

  views.Main = Backbone.View.extend({
    template: hbs.compile($('#root-main-template').html()),
    initialize: function() {
      var self = this;
      self.render();
    },
    render: function(){
      var self = this;
      self.$el.html(self.template({
        metadata: App.pkg.metadata,
        modules: self.parseDoc(App.pkg.metadata),
      }));
      return self;
    },
    parseDoc: function(object) {
      var modules = _.groupBy(object.resources, 'module');
      var out = [];
      for (var module in modules) {
        out.push({
          name: module,
          resources: modules[module]
        });
      };
      return out
    }
  });

})(root);