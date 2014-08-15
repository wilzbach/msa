var opts = {};
opts.seqs = biojs.vis.msa.utils.seqgen.getDummySequences(4,50);
opts.el = document.getElementById('msa_menu');
var msa = new biojs.vis.msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.el = document.getElementById("msa_menubar");
menuOpts.msa = msa;
var defMenu = new biojs.vis.msa.menu.defaultmenu(menuOpts);
//defMenu.createMenu();

msa.addView("menu", defMenu);

var logger = document.getElementById("msa_menu_console");
function log(text){
  message = document.createElement("div");
  message.textContent = text;
  if(logger.childNodes.length > 0){
    logger.insertBefore(message,logger.firstChild);
  }else{
    logger.appendChild(message);
  }
  if(logger.childNodes.length > 10){
    logger.removeChild(logger.lastChild)
  }
}

msa.onAll(function(eventName, data){
  console.log(eventName);
  if(data !== undefined){
    log(eventName  + " triggered with " + JSON.stringify(data));
  } else{
    log(eventName  + " triggered");
  }
});

msa.render();
