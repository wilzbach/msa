var msa = window.msa;

yourDiv.textContent = "loading";

var opts = {};
opts.el = yourDiv;
opts.vis = {
  conserv: false,
  overviewbox: false
};
opts.zoomer = {
  boxRectHeight: 1,
  boxRectWidth: 1,
  alignmentHeight: window.innerHeight * 0.8,
  labelFontsize: 12,
  labelIdLength: 50
};
var m = msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);
m.addView("menu", defMenu);

m.seqs.reset(msa.utils.seqgen.getDummySequences(1000, 300));
m.g.zoomer.set("alignmentWidth", "auto");
m.render();
renderMSA(msa.utils.seqgen.getDummySequences(1000,300));

function renderMSA(seqs) {
  // hide some UI elements for large alignments
  if (seqs.length > 1000) {
    m.g.vis.set("conserv", false);
    m.g.vis.set("metacell", false);
    m.g.vis.set("overviewbox", false);
  }
  m.seqs.reset(seqs);
  m.g.zoomer.set("alignmentWidth", "auto");
  m.render();
}
