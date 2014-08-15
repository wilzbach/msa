var msa = new biojs.vis.msa.msa('msa_menu', biojs.vis.msa.utils.seqgen.getDummySequences(4,50));

// the menu is independent to the MSA container
var defMenu = new biojs.vis.msa.menu.defaultmenu("msa_menubar", msa);
defMenu.createMenu();

var buffer = [];
var logger = document.getElementById("msa_menubar_console");
function log(){
  for(var i=buffer.length-1;i >= 0;i--){
      logger.innerHTML += buffer[i];
  }
}

msa.onAll(function(eventName, data){
  buffer.push("eventName");
  if(buffer.length > 10){
    buffer.pop();
  }
});
