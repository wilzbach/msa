var Feature = msa.model.feature;
var f1 = new Feature({xStart:7 ,xEnd: 20,text: "foo1", fillColor: "red"});
var f2 = new Feature({xStart:21,xEnd: 40,text: "foo2", fillColor: "blue"});
var f3 = new Feature({xStart:10,xEnd: 30,text: "foo3", fillColor: "green"});


var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(10,110);
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

//var regionSelect = new msa.rselect({model: m});
//console.log($("body").get(0).appendChild(regionSelect.el));

// ---------------------------------------------------
//console.log("consensus", msa.algo.consensus(m));

m.onAll(function(eventName, data){
  log(eventName,data);
});

m.g.onAll(function(eventName, data){
  log(eventName,data);
});
m.g.selcol.on("all",function(eventName,data){
  log(eventName + " mod.", data.attributes);
});

var logger = document.getElementById("msa_menu_console");
function log(eventName,data){
  if(data !== undefined){
    text = eventName  + " triggered with " + clean(data);
  } else{
    text = eventName  + " triggered";
  }
  message = document.createElement("div");
  message.textContent = text;
  if(logger.childNodes.length > 0){
    logger.insertBefore(message,logger.firstChild);
  }else{
    logger.appendChild(message);
  }
  if(logger.childNodes.length > 10){
    logger.removeChild(logger.lastChild);
  }
}

// prevent circular refs
function clean(obj){
  var o = {};
  if(typeof obj !== "object"){
    return obj;
  }
  for(var key in obj){
    if(typeof obj[key] !== 'object'){
      o[key] = obj[key];
    }
  }
  return JSON.stringify(o);
}


m.render();
