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

[![Build Status](https://drone.io/github.com/greenify/biojs-vis-msa/status.png)](https://drone.io/github.com/greenify/biojs-vis-msa/latest)
[![NPM version](http://img.shields.io/npm/v/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)
[![Dependencies](https://david-dm.org/greenify/biojs-vis-msa.png)](https://david-dm.org/greenify/biojs-vis-msa)
[![Code Climate](https://codeclimate.com/github/greenify/biojs-vis-msa/badges/gpa.svg)](https://codeclimate.com/github/greenify/biojs-vis-msa)
[![NPM downloads](http://img.shields.io/npm/dm/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)

### Step 1) Embed components

Have a look at the [quick start examples](https://dev.biojs-msa.org/v1)

```
<script src="biojs.js"></script>
<link type="text/css" rel="stylesheet" href="css/msa.css" />
```

The whole API is coming soon.

You can __fetch prebuilt files__ [here](https://drone.io/github.com/greenify/biojs-vis-msa/files)

### Step 2) Developing 

Run `npm install` once to install all dependencies.

```
npm run watch
```

Have fun coding.

### Step 3) Compiling for the browser

```
npm run build-browser
```

TODO:
* all examples snippets are bundled into one file and statically added to the output HTML
* static files (`css`, `samples`) + third party `libs` are copied to `build`
* a Javascript API documentation is generated (coming soon)


### Step 4) Unit Testing

```
npm test
```

Head over to `tests/index.html`. 
Add all you unit tests as module to the index.html. You can write unit tests either in JavaScript or in CoffeeScript.

If you want to run them in the CLI, you need to install NodeJS Package manager (e.g. `apt-get install npm`) and the module `grunt-cli` (`npm install -g grunt-cli`).

Execute once `npm install` to download all other dependencies locally

And now you can execute all unit tests
```
grunt
```

If you wish to let it watch for file changes and rerun the test, use `grunt watch`

### Step 5) Styling
---------

For a complete build you also need SASS. `ruby-sass` or `gem install sass`.

### Documentation

in rebuild

### Used libraries

* [coffeescript](https://github.com/jashkenas/coffee-script)
* [sass](http://sass-lang.com/)

## Used libraries for testing 

* [coffeelint](http://www.coffeelint.org/)
* [grunt](http://gruntjs.com/getting-started)
* [grunt-coffeelint](https://github.com/vojtajina/grunt-coffeelint)
* [grunt-contrib-qunit](https://github.com/gruntjs/grunt-contrib-qunit)
* [grunt-contrib-jshint](https://github.com/gruntjs/grunt-contrib-jshint)
* [grunt-contrib-watch](https://github.com/gruntjs/grunt-contrib-watch)
* [PhantomJS](http://phantomjs.org/)
* [qunit](http://qunitjs.com/)

### Used libraries for the documentation

* [jQuery](https://jquery.com/)
* [highlight.js](http://highlightjs.org/)
