(function(namespace) {

  var views = namespace.views;

  var Router = Backbone.Router.extend({
    
    routes: {
      '': 'main',
    },

    main: function() {
      var xhr = new XMLHttpRequest();
      xhr.open('GET', 'metadata.json', false);
      xhr.send(null);
      var metadataJSON = JSON.parse(xhr.responseText);
      App.pkg.metadata = metadataJSON;
      new views.Main({
        el: $('#container')
      });
    },

  });

  new Router();

})(root);