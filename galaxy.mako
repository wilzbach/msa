var xhr = require("xhr");
var msa = require("msa");

xhr(jsonURL, function(err, response,text){
	var data = JSON.parse(text).data;
	
	if(dataType == "galaxy.datatypes.sequence.Fasta"){
		var seqs = require("biojs-io-fasta").parse(data);
	}else{
		// it could be clustal
		var seqs = require("biojs-io-clustal").parse(data); 
	}

	var m = new msa({
		el: galaxyDiv,
		seqs: seqs,
		zoomer: {
			labelWidth: 200
		},
		bootstrapMenu: true // automatically adds a menu bar
	});
	m.render();
});
