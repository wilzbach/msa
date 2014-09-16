biojs-vis-msa
==========

The BioJS MSA Viewer written in CoffeeScript. 

```
          .         .                                              
         ,8.       ,8.            d888888o.           .8.          
        ,888.     ,888.         .`8888:' `88.        .888.         
       .`8888.   .`8888.        8.`8888.   Y8       :88888.        
      ,8.`8888. ,8.`8888.       `8.`8888.          . `88888.       
     ,8'8.`8888,8^8.`8888.       `8.`8888.        .8. `88888.      
    ,8' `8.`8888' `8.`8888.       `8.`8888.      .8`8. `88888.     
   ,8'   `8.`88'   `8.`8888.       `8.`8888.    .8' `8. `88888.    
  ,8'     `8.`'     `8.`8888.  8b   `8.`8888.  .8'   `8. `88888.   
 ,8'       `8        `8.`8888. `8b.  ;8.`8888 .888888888. `88888.  
,8'         `         `8.`8888. `Y8888P ,88P'.8'       `8. `88888.
```

[![Build Status](https://travis-ci.org/greenify/biojs-vis-msa.svg?branch=master)](https://travis-ci.org/greenify/biojs-vis-msa)
[![NPM version](http://img.shields.io/npm/v/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)
[![Dependencies](https://david-dm.org/greenify/biojs-vis-msa.png)](https://david-dm.org/greenify/biojs-vis-msa)
[![Code Climate](https://codeclimate.com/github/greenify/biojs-vis-msa/badges/gpa.svg)](https://codeclimate.com/github/greenify/biojs-vis-msa)
[![NPM downloads](http://img.shields.io/npm/dm/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)


```html
<script src=//cdn.biojs-msa.org/msa/0.2/msa.min.gz.js></script>
<link type=text/css rel=stylesheet href=//cdn.biojs-msa.org/msa/0.2/msa.min.gz.css />
```

Yes you can either link to the minified, gzipped CDN version or download the dev version from S3 .

JS  | CSS
------------- | -------------
[![Min version](http://img.shields.io/badge/prod-26kB-blue.svg)](https://cdn.biojs-msa.org/msa/latest/msa.min.gz.js)  | [![Min version](http://img.shields.io/badge/prod-2kB-blue.svg)](https://cdn.biojs-msa.org/msa/latest/msa.min.gz.css)
[![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://s3-eu-west-1.amazonaws.com/biojs/msa/latest/msa.js) | [![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://s3-eu-west-1.amazonaws.com/biojs/msa/latest/msa.css)



In case
* Amazon S3 should be ever down, there is a [redundant build server](https://drone.io/github.com/greenify/biojs-vis-msa/files). 
* you need a uglified unzipped CDN version, just remove the `.gz` in the file name.
* you want the latest version, replace the version number with `latest`.

Demo
-----

[![JSBin clustal](http://img.shields.io/badge/jsbin-clustal-blue.svg)](http://jsbin.com/quvex/4/edit?js,output) 
[![JSBin large](http://img.shields.io/badge/jsbin-large-blue.svg)](http://jsbin.com/zunuko/4/edit?html,js,output) 


[Current sniper](http://sniper.biojs-msa.org:9090/snippets/msa_show_menu) with different examples


#### display an MSA

![basic MSA](http://i.imgur.com/39rIcR1l.jpg)

#### zoom in

![zoom in](http://i.imgur.com/tw8AueLl.jpg)

#### choose your favorite color

![color it](http://i.imgur.com/CIUP5lNl.jpg)


####  Features
* runs purely in the Browser
* import files in format like FASTA, Clustal, ...
* be interactive and receive [Events](https://github.com/greenify/biojs-vis-msa/wiki/Events)
* filter, sort, hide the sequences
* display sequence [features](https://github.com/greenify/biojs-vis-easy_features/) 
* extendable [Views](https://github.com/greenify/biojs-vis-msa/wiki/Views) for your integration
* customizable viewport
* simplicity as design rule
* export to fASTA
* generate the consenus seq
* more to come ...


Documentation
-------------

See below and head to the [wiki](https://github.com/greenify/biojs-vis-msa/wiki/).

Please report bugs or feature request directly on github.

Guidelines
-----------

* [KISS](http://en.wikipedia.org/wiki/KISS_principle) -> avoid komplexity
* keep it modular
* avoid boiler-plate code
* avoid more than two args for public methods -> accepting a dictionary is more flexible
* trust the linter (for coffeescript there is a default config)
* max. 200 lines per file (-> better organization)

BTW the use of Coffeescript is optional.


Step 1) Setting up
-----------------

```bash
npm install
```

* __sass__: At the moment the pure [`node-sass`](https://www.npmjs.org/package/node-sass) does not
support SASS 3.3. The setup will try to install the Rubygem sass automatically, if it fails be prepared to run `gem install sass` (as root!). Please do not use the `ruby-sass` package on debian - it is outdated.
* __npm__: You will need the `npm` package manager (and node) for this. On most distributions there is a package, look [here](http://nodejs.org/download/)

__Infos__

* This will also automatically validate your installation by running `gulp build`
 - generating browser builds for the codebase
 - compiling the SASS
 - executing all unit tests 

Step 2) Unit Testing
-------------------------

### Running tests from the CLI


```
npm test
```


If you install gulp globally (`npm install -g gulp`), you can run 

Execute all unit tests
```
gulp test
```

If you wish to let it watch for file changes and rerun the test automatically, use `gulp watch`

### 2.2 Adding your test

* test without DOM interaction, can go into `test/mocha`
* test with DOM interaction (= need to be run by a browser) -> `test/phantom`

Hints for phantom:

* it takes way longer to run phantom tests (headless browser tests), than normal mocha tests
* you need to add your phantom tests to `test/phantom/index.coffee`
* there are sub directives
 - `test-mocha` wil only execute mocha tests
 - `test-phantom` will only execute phantom tests

### 2.3 Debugging tests

Open the `tests/index.html` with your browser and set breakpoints.
Important: the coffeescript is not directly compiled in your browser, so in theory you need to compile everything to `all_tests.js`.
However this is done automatically by `gulp test` or `gulp wacth`.


Step 3) Developing
------------------

```
npm run watch
```

This will use [watchify](https://github.com/substack/watchify) to recompile the JS to the build folder on every change.

Have fun coding.
You can also start [biojs-sniper](https://github.com/greenify/biojs-sniper), to view the snippets. Without global installation, just hit 

```
npm run sniper
```

(then you can browse the snippets at [localhost:9090/snippets](http:localhost:9090/snippets)).


Compiling for the browser
--------------------------------

```
gulp build
```

This is will regenerate the CSS and JS (+minification).
However this is done automatically by Travis (and on `npm install`), so you normally don't need to run it.
(If you can't install gulp globally, hit `npm run preinstall`.).
The minification is done by [Browserify](http://browserify.org/).

CSS & Styling
---------

For a complete build you also need SASS (>= 3.3), `gem install sass`.  
The auto setup will try to fix that, but this only works if you have `bundler` installed.

To recompile the SASS, just run
```
gulp css
```
(this is included in `gulp build`, which was run on npm install)

Project structure
------------------

* `browser.js` main file for browserify - defines the global namespace in the browser
* `coffeelint.json` liniting config for CoffeeScript (run it with `gulp lint`)
* `css` SASS styles (the main one is called `msa.sass`
* `external` external dependencies that are not available in npm (TODO: remove and replace with npm packages)
* `gulpfile.js` task definition file (for [gulp](http://gulpjs.com/])
* `Gemfile` defines the dependency to ruby-sass (needed for the auto-install with bundler)
* `index.js` npm CJS main file - allows to require example the folder (`../`) - convenient for tests
* `package.json` [npm config](https://www.npmjs.org/doc/files/package.json.html)
* `res-docs` external dependencies of the snippets (TODO: cleanup and maybe remove)
* `snippets` short coding snippets that are run by [`biojs-sniper`](https://github.com/greenify/biojs-sniper)
* `sniper.toml` config file for [`biojs-sniper`](https://github.com/greenify/biojs-sniper)
* `src` the main source code
* `test` unit tests that are run with either mocha or phantomjs (headless browser)
