#!/usr/bin/env node

var phantom = require('phantom');

phantom.create(function (ph) {
  ph.createPage(function (page) {

    page.onConsoleMessage(function(msg) { 
      console.log(msg); 
    })
    //page.set('onLoadFinished', function (status) {})

    page.open("./index.html", function (status) {
      ph.exit();
      /*
      page.evaluate(function () { return foo ; }, function (result) {
        console.log('Page title is ' + result);
        ph.exit();
      }) */;
    });
  });
});
