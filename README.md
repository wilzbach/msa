msa
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

[![Build Status](https://travis-ci.org/wilzbach/msa.svg?branch=master)](https://travis-ci.org/wilzbach/msa)
[![NPM version](http://img.shields.io/npm/v/msa.svg)](https://www.npmjs.org/package/msa)
[![Dependencies](https://david-dm.org/wilzbach/msa.png)](https://david-dm.org/wilzbach/msa)
[![Code Climate](https://codeclimate.com/github/wilzbach/msa/badges/gpa.svg)](https://codeclimate.com/github/wilzbach/msa)
[![NPM downloads](http://img.shields.io/npm/dm/msa.svg)](https://www.npmjs.org/package/msa)


```html
<script src=//cdn.biojs.net/msa/0.4/msa.min.gz.js></script>
```

Yes you can either link to the minified, gzipped CDN version or download the dev version from S3 .

[![Min version](http://img.shields.io/badge/prod-35kB-blue.svg)](https://cdn.biojs.net/msa/latest/msa.min.gz.js)  
[![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://s3-eu-west-1.amazonaws.com/biojs/msa/latest/msa.js) 

In case
* Amazon S3 should be ever down, there is a [redundant build server](https://drone.io/github.com/wilzbach/msa/files). 
* you need a uglified unzipped CDN version, just remove the `.gz` in the file name.
* you want the latest version, replace the version number with `latest`.

[![NPM](https://nodei.co/npm/msa.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/msa/)

News
----

* Pure JS version (with ES6 and webpack) in the [`develop`](https://github.com/wilzbach/msa/tree/develop) branch

Use it
------

[Full screen](http://msa.biojs.net/app) mode.

Demo
-----

These examples show how you could embed the MSA viewer into your page.

[![JSBin clustal](http://img.shields.io/badge/jsbin-clustal-blue.svg)](http://jsbin.com/quvex/4/edit?js,output) 
[![JSBin large](http://img.shields.io/badge/jsbin-large-blue.svg)](http://jsbin.com/zunuko/4/edit?html,js,output) 


[Current sniper](http://workmen.biojs.net/demo/msa) with different examples

#### display an MSA

![basic MSA](https://i.imgur.com/nQtfMmI.png)


####  Features
* runs purely in the Browser
* import files in format like FASTA, Clustal, ...
* be interactive and receive [Events](https://github.com/wilzbach/msa/wiki/Events)
* filter, sort, hide the sequences
* display sequence [features](https://github.com/wilzbach/biojs-vis-easy_features/) 
* extendable [Views](https://github.com/wilzbach/msa/wiki/Views) for your integration
* customizable viewport
* simplicity as design rule
* export to fASTAb
* generate the consenus seq
* more to come ...

## Use the MSA viewer

### Import seqs

#### a) Directly import a url

```
var msa = require("msa");
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
};
var m = new msa(opts);
```

#### b) Import your own seqs

```
var msa = require("msa");
var m = new msa({
	el: rootDiv,
	seqs: msa.utils.seqgen.genConservedSequences(10,30, "ACGT-"); // an array of seq files
});
m.render()
```

#### c) Asynchronously import seqs

```
var msa = require("msa");
var clustal = require("biojs-io-clustal");
var m = new msa({
	el: rootDiv,
});
clustal.read("https://raw.githubusercontent.com/wilzbach/msa/master/test/dummy/samples/p53.clustalo.clustal", function(err, seqs){
	m.seqs.reset(seqs);
	m.render();
});
```

### Basic config parameters

* `bootstrapMenu`: automagically show a menu
* `el`: the root DOM element
* `importURL`: when you want to import a file automagically
* `seqs`: if you prefer to pass sequences as object

There also many other option - grouped into these categories. See below for more details.

* `column`: hide columns
* `colorscheme`: everything about a colorscheme
* `conf`: basic configuration
* `vis`:  visual elements
* `visorder`: ordering of the visual elements
* `zoomer`: everything that is pixel-based

### Change the colorscheme

Checkout this [live example](http://workmen.biojs.net/demo/msa/colorscheme) or [edit](http://workmen.biojs.net/jsbin/msa/colorscheme).

```
var msa = require("msa");
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  colorscheme: {"scheme": "hydro"}
};
var m = new msa(opts);
```

Own colorscheme

```
var msa = require("msa");
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  colorscheme: {"scheme": "hydro"}
};
var m = new msa(opts);
m.g.colorscheme.addStaticScheme("own",{A: "orange", C: "red", G: "green", T: "blue"});
m.g.colorscheme.set("scheme", "own");
```

Have a look at the [doc](https://github.com/wilzbach/msa-colorschemes) for more info.


### Add features

Checkout this [live example](http://workmen.biojs.net/demo/msa/fer1_annoted) or [edit](http://workmen.biojs.net/jsbin/msa/fer1_annoted).

```
var msa = require("msa");
var xhr = require("xhr");
var gffParser = require("biojs-io-gff");
var m = msa({el: rootDiv, importURL: "https://raw.githubusercontent.com/wilzbach/msa/master/test/dummy/samples/p53.clustalo.clustal");

// add features
xhr("./data/fer1.gff3", function(err, request, body) {
  var features = gffParser.parseSeqs(body);
  m.seqs.addFeatures(features);
});

// or even more
xhr("./data/fer1.gff_jalview", function(err, request, body) {
  var features = gffParser.parseSeqs(body);
  m.seqs.addFeatures(features);
});
```

### Update seqs

```
m.seqs.at(0).set("hidden", true) // hides the first seq
m.seqs.at(0).get("seq") // get raw seq
m.seqs.at(0).get("seqId") // get seqid
m.seqs.at(0).set("seq", "AAAA") // sets seq
m.seqs.add({seq: "AAA"});  // we add a new seq at the end
m.seqs.unshift({seq: "AAA"});  // we add a new seq at the beginning
m.seqs.pop() // remove and return last seq
m.seqs.shift() // remove and return first seq 
m.seqs.length // nr
m.seqs.pluck("seqId") // ["id1", "id2", ..]
m.seqs.remove(m.seqs.at(2)) // remove seq2
m.seqs.getMaxLength() // 200
m.seqs.addFeatures()
m.seqs.removeAllFeatures()
m.seqs.setRef(m.seqs.at(1)) // sets the second seq as reference (default: first)
m.seqs.comparator = "seqId" // sort after seqId
m.seqs.sort() // apply our new comparator
m.seqs.comparator =  function(a,b){ return - a.get("seq").localeCompare(b.get("seq"))} // sort after the seq itself in descending order
m.seqs.sort()
```

Even [more](http://backbonejs.org/#Collection) is possible.

### Update selection

```
m.g.selcol.add(new msa.selection.rowsel({seqId: "f1"})); // row-based
m.g.selcol.add(new msa.selection.columnsel({xStart: 10, xEnd: 12})); // column-wise
m.g.selcol.add(new msa.selection.possel({xStart: 10, xEnd: 12, seqId: "f1"})); // union of row and column
m.g.selcol.reset([new msa.selection.rowsel({seqId: "f1"})]); // reset
```

```
m.g.selcol.getBlocksForRow() // array of all selected residues for a row
m.g.selcol.getAllColumnBlocks() // array with all selected columns
m.g.selcol.invertRow(@model.pluck "id")
m.g.selcol.invertCol([0,1,2])
m.g.selcol.reset() // remove the entire selection
m.g.user.set("searchText", search) // search 
```

### Jump to a column

```
m.g.zoomer.setLeftOffset(10) // jumps to column 10
```

### Export and save


```
m.utils.export.saveAsFile(m, "all.fasta") // export seqs
m.utils.export.saveSelection(m, "selection.fasta")
m.utils.export.saveAnnots(m, "features.gff3")
m.utils.export.saveAsImg(m,"biojs-msa.png")

// share the seqs with the public = get a public link
m.utils.export.shareLink(m, function(link){
	window.open(link, '_blank')
})

// share via jalview
var url =  m.g.config.get('url')
if url.indexOf("localhost") || url === "dragimport"
    m.utils.export.publishWeb(m, function(link){
    	m.utils.export.openInJalview(link, m.g.colorscheme.get("scheme"))
    });
}else{
    m.utils.export.openInJalview(url, m.g.colorscheme.get("scheme"))
}
```


### Update attributes

```
msa.g.vis.set("marker", false); // hides the markers
msa.g.zoomer.set("alignmentHeight", 500) // modifies the default height
```

### Listen to attribute events

All classes 

```
m.g.selcol.on("change", function(prev, new){

})
```

You can also listen to more specific events

```
m.g.vis.on("change:alignmentWidth", function(prev, new){

})
```

### Listen to user interactions

```
msa.g.on("residue:click", function(data){ ... }):
msa.g.on("residue:mousein", function(data){ ... }):
msa.g.on("residue:mouseout", function(data){ ... }):
```

If you want to listen to mouse events, you need to set the flag: `conf.registerMouseHover`.
There is a plethora of events that you can listen to

```
msa.g.on("row:click", function(data){ ... }):
msa.g.on("column:click", function(data){ ... }):
msa.g.on("meta:click", function(data){ ... }):
...
```


### Config parameters in g

```
conf: {
 	registerMouseHover: false,
    registerMouseClicks: true,
    importProxy: "https://cors-anywhere.herokuapp.com/",
    eventBus: true,
    alphabetSize: 20,
    dropImport: false,
    debug: false,
    hasRef: false // hasReference,
    manualRendering: false // manually control the render (not recommened)
},
colorscheme: {
    scheme: "taylor", // name of your color scheme
    colorBackground: true, // otherwise only the text will be colored
    showLowerCase: true, // used to hide and show lowercase chars in the overviewbox
    opacity: 0.6 //opacity for the residues
},
columns: {
	hidden: [] // hidden columns
}
vis: {
    sequences: true,
    markers: true,
    metacell: false,
    conserv: false,
    overviewbox: false,
    seqlogo: false,
    gapHeader: false,
    leftHeader: true,

    // about the labels
    labels: true,
    labelName: true,
    labelId: true,
    labelPartition: false,
    labelCheckbox: false,

    // meta stuff
    metaGaps: true,
    metaIdentity: true,
    metaLinks: true
},
zoomer: {
    // general
    alignmentWidth: "auto",
    alignmentHeight: 225,
    columnWidth: 15,
    rowHeight: 15,
    autoResize: true // only for the width

    // labels
    textVisible: true,
    labelIdLength: 30,
    labelNameLength: 100,
    labelPartLength: 15,
    labelCheckLength: 15,
    labelFontsize: 13,
    labelLineHeight: "13px",

    // marker
    markerFontsize: "10px",
    stepSize: 1,
    markerStepSize: 2,
    markerHeight: 20,

    // canvas
    residueFont: "13", //in px
    canvasEventScale: 1,

    // overview box
    boxRectHeight: 2,
    boxRectWidth: 2,
    overviewboxPaddingTop: 10,

    // meta cell
    metaGapWidth: 35,
    metaIdentWidth: 40,
    metaLinksWidth: 25
}
```

The menu has its own small set of properties that can be modified. It's the `menu`
property for both the defaultmenu as using the menu bootstrapping.

```
menu: {
    menuFontsize: "14px",
    menuItemFontsize: "14px",
    menuItemLineHeight: "14px",
    menuMarginLeft: "3px",
    menuPadding: "3px 4px 3px 4px",
}
```

### Sequence model

```
{
  name: "",
  id: "",
  seq: "",
  height: 1,
  ref: false // reference: the sequence used in BLAST or the consensus seq
}
```

FAQ
----

Q: How can I define my own color scheme?

↝ [play in JSBin](http://workmen.biojs.net/jsbin/msa/colorscheme)
↝ [read the documentation](https://github.com/wilzbach/msa-colorschemes)

Documentation
-------------

See below and head to the [wiki](https://github.com/wilzbach/msa/wiki/).

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
git clone https://github.com/wilzbach/msa
cd msa
npm install
```

* __npm__: You will need the `npm` package manager (and node) for this. On most distributions there is a package, look [here](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)

__Infos__

* This will also automatically validate your installation by running `gulp build`
 - generating browser builds for the codebase
 - executing all unit tests 

Step 2) Developing
------------------

```
./w
```

(in the root dir)

This will automatically execute these two commands

### 2.1 Watching and recompile

```
npm run watch
```

This will use [watchify](https://github.com/substack/watchify) to recompile the JS to the build folder on every change.

Have fun coding.
You can also start [sniper](https://github.com/wilzbach/sniper), to view the snippets. Without global installation, just hit 

### 2.2 Example (snippets) server

```
npm run sniper
```

(then you can browse the snippets at [localhost:9090/snippets](http:localhost:9090/snippets)).


3) Unit Testing
-------------------------

### 3.1 Running tests from the CLI


```
npm test
```


If you install gulp globally (`npm install -g gulp`), you can run 

Execute all unit tests
```
gulp test
```

If you wish to let it watch for file changes and rerun the test automatically, use `gulp watch`

### 3.2 Adding your test

* test without DOM interaction, can go into `test/mocha`
* test with DOM interaction (= need to be run by a browser) -> `test/phantom`

Hints for phantom:

* it takes way longer to run phantom tests (headless browser tests), than normal mocha tests
* you need to add your phantom tests to `test/phantom/index.coffee`
* there are sub directives
 - `test-mocha` wil only execute mocha tests
 - `test-phantom` will only execute phantom tests

### 3.3 Debugging tests

Open the `tests/index.html` with your browser and set breakpoints.
Important: the coffeescript is not directly compiled in your browser, so in theory you need to compile everything to `all_tests.js`.
However this is done automatically by `gulp test` or `gulp wacth`.


Compiling for the browser
--------------------------------

```
gulp build
```

This is will regenerate the CSS and JS (+minimization).
However this is done automatically by Travis (and on `npm install`), so you __normally don't need to run it__.
(If you can't install gulp globally, hit `npm run preinstall`.).
The minimization is done by [Browserify](http://browserify.org/).

Package list
-----------

↝ [Package list](https://github.com/wilzbach/msa/wiki/Package-list)


Project structure
------------------

* `browser.js` main file for browserify - defines the global namespace in the browser
* `coffeelint.json` linting config for CoffeeScript (run it with `gulp lint`)
* `css` stylesheet folder (previously used for SASS)
* `gulpfile.js` task definition file (for [gulp](http://gulpjs.com/])
* `package.json` [npm config](https://www.npmjs.org/doc/files/package.json.html)
* `snippets` short coding snippets that are run by [`sniper`](https://github.com/wilzbach/sniper)
* `src` the main source code
* `test` unit tests that are run with either mocha or phantomjs (headless browser)

Want to learn more?
-------------------

Continue at the [wiki](https://github.com/wilzbach/msa/wiki).
