/* global yourDiv */
var msa = window.msa;

var opts = {};

opts.el = document.createElement('div');
opts.el.textContent = "loading";

opts.vis = {
  metacell: true,
  overviewbox: true
};
opts.columns = {
  hidden: [1, 2, 3]
};
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);

m.addView("menu", defMenu);

yourDiv.appendChild(defMenu.el);
yourDiv.appendChild(opts.el);

// search in URL for fasta or clustal
function getURLParameter(name) {
  return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
}

if (getURLParameter('fasta') !== null) {
  var url = msa.utils.proxy.corsURL(getURLParameter('fasta'), m.g);
  require("biojs-io-fasta").read(url, renderMSA);
  m.g.conf.set("url", url);
} else if (getURLParameter('clustal') !== null) {
  var url = msa.utils.proxy.corsURL(getURLParameter('clustal'), m.g);
  require("biojs-io-clustal").read(getURLParameter('clustal'), renderMSA);
  m.g.conf.set("url", url);
} else {
  m.seqs.reset(msa.utils.seqgen.getDummySequences(18, 110));

  // display features
  var Feature = msa.model.feature;
  var f1 = new Feature({
    xStart: 7,
    xEnd: 20,
    text: "foo1",
    fillColor: "red"
  });
  var f2 = new Feature({
    xStart: 21,
    xEnd: 40,
    text: "foo2",
    fillColor: "blue"
  });
  var f3 = new Feature({
    xStart: 10,
    xEnd: 30,
    text: "foo3",
    fillColor: "green"
  });
  m.seqs.at(1).set("features", new msa.model.featurecol([f1, f2, f3]));

  m.g.zoomer.set("alignmentWidth", "auto");
  m.render();

  var overviewbox = m.getView("stage").getView("overviewbox");
  overviewbox.el.style.marginTop = "30px";
}

function renderMSA(err, seqs) {
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

//instance=m.g
