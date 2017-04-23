var exec = require('cordova/exec');

exports.showNav = function(arg0, success, error) {
    exec(success, error, "YswNavigation", "showNav", [arg0]);
};
