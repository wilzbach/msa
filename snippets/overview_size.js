/* global rootDiv */

// restrict the width
rootDiv.setAttribute('style', 'width: 300px');

var msa = window.msa;
var opts = {
  importURL: "./data/fer1.clustal",
  vis: {
    overviewbox: true
  }
};

var appendTitle = function(el, title) {
  var t = document.createElement("h3");
  t.appendChild( document.createTextNode( title ) );
  el.appendChild( t );
};

// default config
var msa_default = new msa(opts);
appendTitle( rootDiv, "Default" );
rootDiv.appendChild(msa_default.el);
msa_default.render();

// explicitly set 'fixed'
opts.zoomer = {
  overviewboxWidth: "fixed"
};
var msa2 = new msa(opts);
appendTitle( rootDiv, "overviewboxWidth: 'fixed'" );
rootDiv.appendChild(msa2.el);
msa2.render();

// explicitly set 'auto'
opts.zoomer = {
  overviewboxWidth: "auto"
};
var msa3 = new msa(opts);
appendTitle( rootDiv, "overviewboxWidth: 'auto'" );
rootDiv.appendChild(msa3.el);
msa3.render();

// boxRectWidth/Height - maybe this should be selected automatically?
opts.zoomer = {
  overviewboxWidth: "auto",
  overviewboxHeight: "fixed", 
  boxRectWidth: 2,
  boxRectHeight: 2
};
var msa4 = new msa(opts);
appendTitle( rootDiv, "overviewboxWidth: 'auto', boxRectWidth=2, boxRectHeight=2" );
rootDiv.appendChild(msa4.el);
msa4.render();

// check the height
opts.zoomer = {
  overviewboxWidth: "fixed",
  overviewboxHeight: 50, 
};
var msa5 = new msa(opts);
appendTitle( rootDiv, "overviewboxHeight: 50" );
rootDiv.appendChild(msa5.el);
msa5.render();

//@biojs-instance=m.g
