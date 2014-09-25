var msa = biojsVisMsa;
yourDiv.textContent = "loading";

var opts = {};
opts.el = yourDiv;
opts.vis = {conserv: false, overviewbox: false}
opts.zoomer = {boxRectHeight: 1, boxRectWidth: 1, alignmentHeight: window.innerHeight * 0.8, labelWidth: 120,labelFontsize: "12px",labelIdLength: 50}
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
var menuDiv = document.createElement('div');
document.body.appendChild(menuDiv);
menuOpts.el = menuDiv;
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);
//defMenu.createMenu();

m.addView("menu", defMenu);

// search in URL for fasta or clustal
function getURLParameter(name) {return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null}

if( getURLParameter('fasta') !== null ){
  var url = msa.utils.proxy.corsURL(getURLParameter('fasta'), m.g);
  biojs.io.fasta.parse.read(url, renderMSA);
} else  if( getURLParameter('clustal') !== null ){
  var url = msa.utils.proxy.corsURL(getURLParameter('clustal'), m.g);
  biojs.io.clustal(getURLParameter('clustal'), renderMSA)
}else{
  m.seqs.reset(msa.utils.seqgen.getDummySequences(1000,300));
  m.g.zoomer.set("alignmentWidth", "auto");
  m.render();
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
