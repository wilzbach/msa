var Feature = msa.model.feature;
var f1 = new Feature({xStart:7 ,xEnd: 20,text: "foo1", fillColor: "red"});
var f2 = new Feature({xStart:21,xEnd: 40,text: "foo2", fillColor: "blue"});
var f3 = new Feature({xStart:10,xEnd: 30,text: "foo3", fillColor: "green"});


var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(18,110);
opts.el = document.getElementById('msa_menu');
//opts.zoomer = { textVisible: false};
opts.vis = {metacell: true, overviewbox: true};
opts.columns = {hidden: [1,2,3]};
var m = new msa.msa(opts);
m.seqs.at(1).set("features", new msa.model.featurecol([f1,f2,f3]));

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.el = document.getElementById("msa_menubar");
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);
//defMenu.createMenu();

m.addView("menu", defMenu);
m.render();


var overviewbox = m.getView("stage").getView("overviewbox");
overviewbox.el.style.marginTop = "30px";

// ---------------------------------------------------
//console.log("consensus", msa.algo.consensus(m));


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

// prevent circular refs
function removeCircularRefs(obj){
  return JSON.stringify(obj, function( key, value) {
    if( key == 'parent') { return value.id;}
    else {return value;}
  })
}
