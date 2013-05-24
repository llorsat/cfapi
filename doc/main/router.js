window.MainRouter = Backbone.Router.extend({
  
  routes: {
    '*actions': 'defaultRoute',
  },
  
  defaultRoute: function() {}

});
