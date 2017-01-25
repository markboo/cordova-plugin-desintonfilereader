
var exec = require('cordova/exec');

var DesintonFileReader = {

    init: function() {
        return new DesintonFileReader();
    },
    
    startWork: function( api_key, successCallback ) {
        exec(
            successCallback,
            function() {
                console.log('fail to startWork');
            },
            'DesintonFileReader',
            'startWork',
            [api_key]
        );
    },
    
    DesintonFileReader: DesintonFileReader
      
}

module.exports = DesintonFileReader;