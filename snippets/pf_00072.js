var msa = window.msa;
yourDiv.textContent = "loading. please wait."
var fasta = msa.io.fasta;

fasta.read('https://cdn.rawgit.com/wilzbach/msa-example-files/master/PF00072_rp15.txt', function(err, seqs) {
  var opts = {};
  opts.seqs = seqs;
  opts.el = yourDiv;
  opts.vis = {
    conserv: false,
    overviewbox: false
  }
  opts.zoomer = {
    boxRectHeight: 1,
    boxRectWidth: 1,
    labelNameLength: 200,
    labelFontsize: 12,
    labelIdLength: 50,
    alignmentHeight: window.innerHeight * 0.85
  }
  var m = msa(opts);

  // the menu is independent to the MSA container
  var menuOpts = {};
  var menuDiv = document.createElement('div');
  document.body.appendChild(menuDiv);
  menuOpts.el = menuDiv;
  menuOpts.msa = m;
  var defMenu = new msa.menu.defaultmenu(menuOpts);
  //defMenu.createMenu();

  m.addView("menu", defMenu);

  m.render();

});
