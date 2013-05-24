/*
 * Your views here
 */
(function(namespace) {
    
    var views = namespace.views;
    
    views.SignInView = Bb.View.extend({
        el: '#signin-container',
        template: hbs.compile($('#signin-template').html()),
        initialize: function() {
            var me = this;
            me.model = user;
            me.render();
        },
        render: function() {
            var me = this;
            me.$el.html(me.template());
            me.$el.fadeIn('slow');
        },
        events: {
            'submit': 'onEnter',
        },
        onEnter: function(e) {
            e.stopPropagation();
            e.preventDefault();
            var me = this;
            me.model.set(formToJSON(me.$('form')));
            me.model.signIn(function() {
                me.$el.fadeOut('slow', function() {
                    new views.HomeView();
                });
            });
            return false;
        }
    });

    views.HomeView = Bb.View.extend({
        el: '#home-container',
        template: hbs.compile($('#home-template').html()),
        initialize: function() {
            var me = this;
            me.render();
        },
        render: function() {
            var me = this;
            me.$el.html(me.template({
                metadata: App.get('metadata'),
            }));
            me.$el.fadeIn('slow');
        },
        events: {
            'click #vitrine': 'onOpenVitrine',
            'click #message': 'onShowMessage',
            'click #logout': 'onLogOut',
        },
        onOpenVitrine: function() {
            var me = this;
            me.openVitrine({
                vitrineId: 'vitrina-unica',
                vitrineTitle: 'Nueva vitrine',
                vitrineHeight: '300px',
                draggable: true,
                closable: true,
                minimizable: true,
            }, function() {});
        },
        onShowMessage: function() {
            var me = this;
            me.showMessage({
                title: 'Este es un error',
                message: 'Esta es una explicación de ejemplo'
            });
            return false;
        },
        onLogOut: function() {
            localStorage.clear();
            location.href = 'index.html';
            return false;
        }
    });

})(auth);
