var options=  {
  transform: ['coffeeify'],
  extensions: ['.coffee'],

};
var watchify = require("watchify");
var browserify = require("browserify");
debugger;
var b = new browserify("browser.js",options);
