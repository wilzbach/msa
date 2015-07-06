var msa = require("msa");

galaxy.getData(function(data, req){

	if(galaxy.dataType == "galaxy.datatypes.sequence.Fasta"){
		var seqs = require("biojs-io-fasta").parse(data);
	}else{
		var seqs = require("biojs-io-clustal").parse(data); 
	}

	var m = new msa({
		el: galaxy.el,
		seqs: seqs,
		zoomer: {
			labelWidth: 200
		},
		bootstrapMenu: true // automatically adds a menu bar
	});
	m.render();
});
