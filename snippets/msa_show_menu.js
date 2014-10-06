var msa = require("biojs-vis-msa");

var opts = {};

opts.el = document.getElementById('msa_menu');
opts.el.textContent = "loading";

//opts.zoomer = { textVisible: false};
opts.vis = {metacell: true, overviewbox: true};
opts.columns = {hidden: [1,2,3]};
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.el = document.getElementById("msa_menubar");
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);

m.addView("menu", defMenu);


// search in URL for fasta or clustal
function getURLParameter(name) {return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null}

if( getURLParameter('fasta') !== null ){
  var url = msa.utils.proxy.corsURL(getURLParameter('fasta'), m.g);
  require("biojs-io-fasta").parse.read(url, renderMSA);
} else  if( getURLParameter('clustal') !== null ){
  var url = msa.utils.proxy.corsURL(getURLParameter('clustal'), m.g);
  require("biojs-io-clustal").read(getURLParameter('clustal'), renderMSA)
}else{
  m.seqs.reset(msa.utils.seqgen.getDummySequences(18,110));

  // display features
  var Feature = msa.model.feature;
  var f1 = new Feature({xStart:7 ,xEnd: 20,text: "foo1", fillColor: "red"});
  var f2 = new Feature({xStart:21,xEnd: 40,text: "foo2", fillColor: "blue"});
  var f3 = new Feature({xStart:10,xEnd: 30,text: "foo3", fillColor: "green"});
  m.seqs.at(1).set("features", new msa.model.featurecol([f1,f2,f3]));

  m.g.zoomer.set("alignmentWidth", "auto");
  m.render();
  
  var overviewbox = m.getView("stage").getView("overviewbox");
  overviewbox.el.style.marginTop = "30px";
}
function renderMSA(seqs){
  // hide some UI elements for large alignments
  if(seqs.length > 1000){
    m.g.vis.set("conserv", false);
    m.g.vis.set("metacell", false);
    m.g.vis.set("overviewbox", false);
  }
  m.seqs.reset(seqs);
  m.g.zoomer.set("alignmentWidth", "auto");
  m.render();
}

// listen to all events on the global event bus
m.g.onAll(function(eventName, data){
  log(eventName,data);
});

// BEGIN: Simple event logging system

var logger = document.getElementById("msa_menu_console");
function log(eventName,data){
  if(data !== undefined){
    text = eventName  + " triggered with " + removeCircularRefs(data);
  }
  message = document.createElement("div");
  message.textContent = text;

  // insert the div always at the top
  if(logger.childNodes.length > 0){
    logger.insertBefore(message,logger.firstChild);
  }else{
    logger.appendChild(message);
  }

  // cleanup
  if(logger.childNodes.length > 10){
    logger.removeChild(logger.lastChild);
  }
}

//instance=m.g

// prevent circular refs
function removeCircularRefs(obj){
  return JSON.stringify(obj, function( key, value) {
    if( key == 'parent') { return value.id;}
    else {return value;}
  })
}
