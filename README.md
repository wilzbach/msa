MSAViewer
==========

Multiple Sequence Alignment Viewer - the MSAViewer - a BioJS component.

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
[![Join the chat at https://gitter.im/wilzbach/msa](https://badges.gitter.im/wilzbach/msa.svg)](https://gitter.im/wilzbach/msa?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Dependencies](https://david-dm.org/wilzbach/msa.png)](https://david-dm.org/wilzbach/msa)
[![Code Climate](https://codeclimate.com/github/wilzbach/msa/badges/gpa.svg)](https://codeclimate.com/github/wilzbach/msa)
[![NPM downloads](http://img.shields.io/npm/dm/msa.svg)](https://www.npmjs.org/package/msa)


```html
<script src=//cdn.bio.sh/msa/1.0/msa.min.gz.js></script>
```

Yes you can either link to the minified, gzipped CDN version or download the dev version from S3 .

[![Min version](http://img.shields.io/badge/prod-35kB-blue.svg)](https://cdn.bio.sh/msa/latest/msa.min.gz.js)
[![Dev version](http://img.shields.io/badge/dev-latest-yellow.svg)](https://cdn.bio.sh/msa/latest/msa.js)

[![NPM](https://nodei.co/npm/msa.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/msa/)

Use it
------

[Full screen](http://msa.biojs.net/app) mode.

Demo
-----

These examples show how you could embed the MSAViewer into your page.

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

## Use the MSAViewer

**The following examples assume that the ```msa()``` constructor is available.**

If you have loaded ```msa``` as a script in your web page with something like...
```
<script src="//cdn.bio.sh/msa/latest/msa.min.gz.js"></script>
```
... then congratulations! You are ready to go.

If you are using ```npm``` and are adding msa as a dependency, then you can use the following:
```
var msa = require("msa");
```

### Import seqs

#### a) Directly import a url

```js
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
};
var m = msa(opts);
```

-> [JSBin example](http://jsbin.com/yusifufiwa/1/edit?js,output)

### b) Import your own sequences from a string

```js
// your fasta file (advice: save it in a DOM node)
var fasta = ">seq1\n\
ACTG\n\
>seq2\n\
ACGG\n";

// parsed array of the sequences
var seqs =  msa.io.fasta.parse(fasta);

var m = msa({
     el: rootDiv,
     seqs: seqs
});
m.render();
```

-> [JSBin Example](http://jsbin.com/zutaqofuro/1/edit?html,js,output)

#### c) Asynchronously import seqs

```js
var m = msa({
	el: rootDiv,
});
msa.io.clustal.read("https://raw.githubusercontent.com/wilzbach/msa/master/test/dummy/samples/p53.clustalo.clustal", function(err, seqs){
	m.seqs.reset(seqs);
	m.render();
});
```

-> [JSBin example](http://jsbin.com/zesihapede/1/edit)

### d) Import your sequences from the DOM

```js
var fasta = document.getElementById("fasta-file").innerText;
var seqs = msa.io.fasta.parse(fasta);

var m = msa({
    el: rootDiv,
    seqs: seqs
});
m.render();
```

with the following data stored in your HTML page:

```html
<pre style="display: none" id="fasta-file">
>seq1
ACTG
>seq2
ACGG</pre>
```

-> [JSBin Example](http://jsbin.com/megecapene/1/edit?html,js,output)

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

## Getting help

Please open an [issue](https://github.com/wilzbach/msa/issues/new)
or ping us on [Gitter](https://gitter.im/wilzbach/msa)

### MSAViewer in Action

- [VaPoR](http://vapor.biojs.tgac.ac.uk)
- [CATH](http://www.cathdb.info/) - [example](http://cathdb.info/version/v4_1_0/superfamily/3.40.50.620/funfam/89168/alignment)
- [Gene3D](http://gene3d.biochem.ucl.ac.uk/) - [Paper](http://nar.oxfordjournals.org/content/early/2015/11/16/nar.gkv1231.full#F1), [example](http://gene3d.biochem.ucl.ac.uk/model?smd5=408c333701ec7e889d495aeb32d7ae10;regs=81_147;fam=2.30.30.40.FF19354;mregs=81_147;cath_mod=na)
- [msaR](https://github.com/bene200/msaR) - Visualize an MSA as interactive R plot or shiny widget
- [MPI Bioinformatics Toolkit for protein sequence analysis](http://toolkit.tuebingen.mpg.de/sections/alignment)
- [PolyMarker](http://www.ncbi.nlm.nih.gov/pubmed/25649618)
- [Galaxy visualization plugin](http://www.benjamenwhite.com/2015/07/biojs2galaxy-a-step-by-step-guide)
- [BitterDB](http://bitterdb.agri.huji.ac.il/bitterdbtest/dbbitter.php#ReceptorAlignment)
- [@thejmazz's _JavaScript and Bioinformatics_ tutorial](https://github.com/thejmazz/js-bioinformatics-exercise)
- [Center for Phage Technology](https://cpt.tamu.edu/clustalw-msa-and-visualisations)
- [PHYLOViZ Online](https://online.phyloviz.net)
- [HistoneDB 2.0](https://www.ncbi.nlm.nih.gov/projects/HistoneDB2.0/index.fcgi/browse/)

Are you using the MSAViewer? Don't hesistate to make a PR and let us know!

### Change the colorscheme

Checkout this [live example](http://workmen.biojs.net/demo/msa/colorscheme) or [edit](http://workmen.biojs.net/jsbin/msa/colorscheme).

```
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  colorscheme: {"scheme": "hydro"}
};
var m = msa(opts);
```

Own colorscheme

```
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  colorscheme: {"scheme": "hydro"}
};
var m = msa(opts);
m.g.colorscheme.addStaticScheme("own",{A: "orange", C: "red", G: "green", T: "blue"});
m.g.colorscheme.set("scheme", "own");
```

Have a look at the [doc](https://github.com/wilzbach/msa-colorschemes) for more info.


### Add features

Checkout this [live example](http://workmen.biojs.net/demo/msa/fer1_annoted) or [edit](http://workmen.biojs.net/jsbin/msa/fer1_annoted).

```
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
    autoResize: true, // only for the width

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

Guidelines
-----------

* [KISS](http://en.wikipedia.org/wiki/KISS_principle) -> avoid komplexity
* keep it modular
* avoid boiler-plate code
* avoid more than two args for public methods -> accepting a dictionary is more flexible
* max. 200 lines per file (-> better organization)

Step 1) Setting up
-----------------

```bash
git clone https://github.com/wilzbach/msa
cd msa
npm install
```

* __npm__: You will need the `npm` package manager (and node) for this.
On most distributions there is a package, look [here](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager)

Step 2) Developing
------------------

In the root dir execute:

```
./w
```

You can browse the snippets at [localhost:9090/snippets](http:localhost:9090/snippets).

Compiling for the browser
--------------------------

For most cases using our CDN builds, is the best way to go.
If you need to make some changes to the MSA, you can get a minified bundle in
the folder `dist` with:

```
gulp build
```

Package list
-----------

↝ [Package list](https://github.com/wilzbach/msa/wiki/Package-list)

Project structure
------------------

* `browser.js` main file for browserify - defines the global namespace in the browser
* `css` stylesheet folder (previously used for SASS)
* `gulpfile.js` task definition file (for [gulp](http://gulpjs.com/])
* `package.json` [npm config](https://www.npmjs.org/doc/files/package.json.html)
* `examples` short coding snippets that are run by [`sniper`](https://github.com/biojs/sniper)
* `src` the main source code

Want to learn more?
-------------------

Continue at the [wiki](https://github.com/wilzbach/msa/wiki).

Getting involved
----------------

Just pick a open issue on the [issue tracker](https://github.com/wilzbach/msa/issues)
and help to make the MSAViewer better.

The best way to get your feature request is to send us a pull request.
Don't worry about simple implementations, we will help you to make it better.

For more questions, ping us on the issue tracker or [Gitter](https://gitter.im/wilzbach/msa).

Team
----

Without the help of these awesome people the MSAViewer project wouldn't have been possible:

Sebastian Wilzbach (Technical University of Munich; TUM), Ian Sillitoe (University College London), Benedikt Rauscher (TUM), Robert Sheridan (Harvard Medical School), James Procter (University of Dundee), Suzanna Lewis (Berkeley), Burkhard Rost (TUM), Tatyana Goldberg(TUM) and Guy Yachdav (TUM).

Do you want to be part of the team? Just grab an issue and send us a PR!
Ask us on [Gitter](https://gitter.im/wilzbach/msa) if you need help to get started.

Versioning & CDN
----------------

New MSA versions are released following [semantic versioning](http://semver.org/).
Starting from 1.0.3 [git tags](https://github.com/wilzbach/msa/tags) match the versions deployed on npm and our CDN.
On our CDN we offer four different versions:  

```
https://cdn.bio.sh/msa/1.0.3/msa.min.gz.js // static, won't change
https://cdn.bio.sh/msa/1.0/msa.min.gz.js // will be updated until a new minor version is released
https://cdn.bio.sh/msa/1/msa.min.gz.js // will be updated until a new major version is released
https://cdn.bio.sh/msa/latest/msa.min.gz.js // will be updated on every commit
```

If you use the MSAViewer in production, we recommend to lock the CDN version to an exact release and update from time to time.

License
-------

This project is licensed under the [Boost Software License 1.0](https://github.com/wilzbach/msa/blob/master/LICENSE).

> Permission is hereby granted, free of charge, to any person or organization
> obtaining a copy of the software and accompanying documentation covered by
> this license (the "Software") to use, reproduce, display, distribute,
> execute, and transmit the Software, and to prepare derivative works of the
> Software, and to permit third-parties to whom the Software is furnished to
> do so, all subject to the following:

If you use the MSAViewer on your website, it solely requires you to link to us.

Citing the MSAViewer
--------------------

The MSAViewer has been published :tada:

Please cite [this paper](http://bioinformatics.oxfordjournals.org/content/early/2016/07/12/bioinformatics.btw474.abstract), when you use the MSAViewer in your project.

> Guy Yachdav and Sebastian Wilzbach and Benedikt Rauscher and Robert Sheridan and Ian Sillitoe and James Procter and Suzanna Lewis and Burkhard Rost and Tatyana Goldberg. "MSAViewer: interactive JavaScript visualization of multiple sequence alignments." Bioinformatics (2016)

As Bibtex:

```
@Article{msaviewer,
   Author = {Guy Yachdav and Sebastian Wilzbach and Benedikt Rauscher and Robert Sheridan and Ian Sillitoe and James Procter and Suzanna Lewis and Burkhard Rost and Tatyana Goldberg},
   Title="{{M}{S}{A}{V}iewer: interactive {J}ava{S}cript visualization of multiple sequence alignments}",
   Journal="Bioinformatics",
   Year="2016",
   Pages=" ",
   Month="Jul",
   Doi = {10.1093/bioinformatics/btw474},
   Url = {http://dx.doi.org/10.1093/bioinformatics/btw474}
}
```
