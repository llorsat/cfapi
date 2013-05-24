/*
* Your views here
*/

(function(namespace) {

  var views = namespace.views;
  var models = namespace.models;

  views.Index = Backbone.View.extend({
    template: hbs.compile($('#documentation-template').html()),
    initialize: function() {
      var self = this;
      self.render();
    },
    render: function(){
      var self = this;
      self.$html(self.template({
        metadata: App.get('metadata'),
        modules: self.parseDoc(App.get('metadata')),
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

})(documentation);