var msa = new biojs.vis.msa.msa(yourDiv);

// inheritance in JS
AwesomeScheme = function(){};
AwesomeScheme.prototype = new biojs.vis.msa.colorator();

// choosing between two colors depending on the numerical value of the char
AwesomeScheme.prototype.colorResidue = function (aminoGroup, tSeq, pos){

  var residue = tSeq.seq[pos];
  var intOfResidue = residue.charCodeAt(0) - 65;
  if( intOfResidue < 10){
    aminoGroup.style.backgroundColor = "rgba(255, 0, 0,0.3)";
  }else if( intOfResidue < 20){
    aminoGroup.style.backgroundColor = "rgba(0, 255, 0,0.3)";
  }else{
    aminoGroup.style.backgroundColor = "rgba(0, 0, 255,0.3)";
  }

  aminoGroup.className = "biojs_msa_single_residue";
}; 

// overwrite selection callbacks
var simpleRed = function (aminoGroup, tSeq, pos){
  aminoGroup.style.backgroundColor = "rgba(255, 0, 0,0.7)";
};

AwesomeScheme.prototype.colorSelectedResidue =   simpleRed;
AwesomeScheme.prototype.colorSelectedResidueSingle =  simpleRed;
AwesomeScheme.prototype.colorSelectedResidueColumn = simpleRed;

msa.colorscheme = new AwesomeScheme();
msa.seqmgr.addDummySequences();
