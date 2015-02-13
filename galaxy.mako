galaxyMenu = document.createElement("div");
galaxyMain = document.createElement("div");
galaxyDiv.appendChild(galaxyMenu);
galaxyDiv.appendChild(galaxyMain);

var xhr = require("xhr");
xhr(jsonURL, function(err, response,text){
	var data = JSON.parse(text).data;
	
	if(dataType == "galaxy.datatypes.sequence.Fasta"){
		var seqs = require("biojs-io-fasta").parse.parse(data);
	}else{
		// it could be clustal
		var seqs = require("biojs-io-clustal").parse(data); 
	}
	
	var msa = require("msa");
	
	var opts = {};
	
	opts.el = galaxyMain; 
	opts.seqs = seqs;
	
	//opts.zoomer = { textVisible: false};
	opts.vis = {overviewbox: true};
	//opts.columns = {hidden: [1,2,3]};
	opts.zoomer = {labelWidth: 200};
	var m = new msa.msa(opts);
	
	// the menu is independent to the MSA container
	var menuOpts = {};
	menuOpts.el = galaxyMenu;
	menuOpts.msa = m;
	var defMenu = new msa.menu.defaultmenu(menuOpts);
	m.addView("menu", defMenu);
	
	m.render();
});
