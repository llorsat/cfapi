/*
 * Your models here
 */
(function(namespace) {

    var models = namespace.models;
    var views = namespace.views;

    models.User = Bb.Model.extend({
        idAttribute: 'token', //change by your id attribute
        loginURL: function() {
            return uri('');
        },
        signIn: function(callback) {
            var me = this;
            setLanguage(me.get('language'));
            // Delete 4 code lines below when start development
            localStorage.session = JSON.stringify(me.toJSON());
            if (_.isFunction(callback)) {
                callback();
            }
            // Uncomment code block below to allow signin
            /*
            $.post(
                me.loginURL(),
                me.toJSON(),
                function(out) {
                    var data = out.admin;
                    me.set(data);
                    localStorage.session = JSON.stringify(me.toJSON());
                    if (_.isFunction(callback)) {
                        callback();
                    }
                },
                'json'
            );
            */
            return false;
        }
    });

})(auth);
