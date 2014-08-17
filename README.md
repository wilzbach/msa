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
[![Build Status](https://drone.io/github.com/greenify/biojs-vis-msa/status.png)](https://drone.io/github.com/greenify/biojs-vis-msa/latest)
[![NPM version](http://img.shields.io/npm/v/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)
[![Dependencies](https://david-dm.org/greenify/biojs-vis-msa.png)](https://david-dm.org/greenify/biojs-vis-msa)
[![Code Climate](https://codeclimate.com/github/greenify/biojs-vis-msa/badges/gpa.svg)](https://codeclimate.com/github/greenify/biojs-vis-msa)
[![NPM downloads](http://img.shields.io/npm/dm/biojs-vis-msa.svg)](https://www.npmjs.org/package/biojs-vis-msa)


```html
<script src=https://d3hiicay54k76t.cloudfront.net/msa/latest/biojs_vis_msa.min.js></script>
<link type=text/css rel=stylesheet href=https://d3hiicay54k76t.cloudfront.net/msa/msa.min.css />
```

![Amazon S3](https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/AmazonWebservices_Logo.svg/500px-AmazonWebservices_Logo.svg.png)

Yes you can either download the dev version from S3 or link to the minified CDN version.

JS  | CSS
------------- | -------------
[![Min version](http://img.shields.io/badge/prod-80kB-blue.svg)](https://d3hiicay54k76t.cloudfront.net/msa/latest/biojs_vis_msa.min.js)  | [![Min version](http://img.shields.io/badge/prod-18kB-blue.svg)](https://d3hiicay54k76t.cloudfront.net/msa/latest/msa.min.css)
[![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://s3-eu-west-1.amazonaws.com/biojs/msa/latest/biojs_vis_msa.js) | [![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://s3-eu-west-1.amazonaws.com/biojs/msa/latest/msa.css)



In case Amazon S3 should be ever down, there is a [redundant build server](https://drone.io/github.com/greenify/biojs-vis-msa/files).

Demo
-----

Have a look at the [quick start examples](https://dev.biojs-msa.org/v1)

(in rebuild)

Head to [Codepen](http://codepen.io/greenify/pen/ALFjq) or [CSSDeck](http://cssdeck.com/labs/swxfsfhe) for a nice example.

Documentation
-------------

online [Codo](http://coffeedoc.info/github/greenify/biojs-vis-msa/master/)
[wiki](https://github.com/greenify/biojs-vis-msa/wiki/)

offline 

```bash
gem install sass
npm install
npm gulp codo
```

and open `build/codo`

At the moment the pure [`node-sass`](https://www.npmjs.org/package/node-sass) does not
support SASS 3.3.

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
gulp test
```

If you wish to let it watch for file changes and rerun the test, use `grunt watch`

### Step 5) Styling
---------

For a complete build you also need SASS. `ruby-sass` or `gem install sass`.

