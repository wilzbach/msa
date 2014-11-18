var through = require('through2');
var phantom = require('phantom');

module.exports = function phantomRunner(options) {
  options = options || {};

  return through.obj(function (file, enc, cb) {

    console.log("starting performance tests. this may take a while");

    // start phantom web page
    phantom.create(function (ph) {
      ph.createPage(function (page) {

        page.onConsoleMessage(function(msg) { 
          console.log(msg); 
        })
        //page.set('onLoadFinished', function (status) {})

        page.open(file.path, function (status) {
          ph.exit();
          cb();
          /*
             page.evaluate(function () { return foo ; }, function (result) {
             console.log('Page title is ' + result);
             ph.exit();
             }) */;
        });
      });
    });

  }.bind(this));
};
