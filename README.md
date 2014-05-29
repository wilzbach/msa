biojs-msa-amd
==========

The BioJS MSA Viewer written in CoffeeScript and AMD modules

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


### Step 1) Embed components

Have a look at the [quick start examples](https://cdn.rawgit.com/greenify/biojs-msa-amd/master/msa.html).

```
<script src="biojs.js"></script>
<link type="text/css" rel="stylesheet" href="css/msa.css" />
```

This library is [AMD-compatible](#), so you can also embedd it with an AMD loader of your choice.

The whole API is coming soon.

### Step 2) Developing 

[`msa.html`](https://cdn.rawgit.com/greenify/biojs-msa-amd/master/msahtml)

* all javascript modules are loaded on demand
* CoffeeScript is compiled by the Browser

All source files are located in `js`

* If you write a module in CoffeeScript, use `.coffee` as an extension and prefix the module with `cs!`
* Apart from dependencies you need to add your new module to the `main.js` (otherwise it won't be bundles into the single file)

Have fun coding.

### Step 3) Compiling


* all sources are bundled to one JS file (`build/biojs.js`)
* CoffeeScript is compiled by R.js
* `biojs.js` gets minified
* all examples snippets are bundled into one file and statically added to the output HTML
* two versions of the documentation are generated (with and without AMD loader)
* static files (`css`, `samples`) + third party `libs` are copied to `build`
* a Javascript API documentation is generated (coming soon)

```
python3 build.py
```


You might need install the Python module `lxml`, therefore run
```
pip3 install lxml 
```

### Just building biojs.js

Maybe you don't have python installed, here are some solutions how you could call the `r.js` compiler


with Node:
```
node js/libs/r.js -o build.js
```

with Java:
```
java -classpath jars/rhino.jar:jars/compiler.jar org.mozilla.javascript.tools.shell.Main js/libs/r.js -o build.js
```

### Step 4) Unit Testing

Head over to `tests/index.html`. 
Add all you unit tests as module to the index.html. You can write unit tests either in JavaScript or in CoffeeScript.

If you want to run them in the CLI, you need to install NodeJS Package manager (e.g. `apt-get install npm`) and the module `grunt-cli` (`npm install -g grunt-cli`).

(Once) execute `npm install` to download all other dependencies locally

And now you can execute all unit tests
```
grunt
```

If you wish to let it watch for file changes and rerun the test, use `grunt watch`

### Documentation

1) [`prod_amd.html`](#)
users has an AMD loader (RequireJS). BioJS is loaded as a AMD dependency.
 
2) [`prod_non_amd.html`](#)
users has no AMD loader. BioJS automatically uses almond and registers as global variable


### Used libraries

* [coffeescript](https://github.com/jashkenas/coffee-script)
* [require.js](https://github.com/jrburke/requirejs)
* [require-cs](https://raw.githubusercontent.com/jrburke/require-cs/latest/cs.js)
* [r.js](https://github.com/jrburke/r.js/)
* [almond](https://github.com/jrburke/almond)

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
