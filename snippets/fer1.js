yourDiv.textContent = "loading. please wait."

biojs.io.clustal.read('http://www.corsproxy.com/rostlab.org/~goldberg/jalv_example.clustal', function(seqs) {
var opts = {};
opts.seqs = seqs;
opts.el = yourDiv;
opts.vis = {conserv: true, overviewbox: true}
opts.zoomer = {boxRectHeight: 10, boxRectWidth: 10, labelWidth: 210,labelFontsize: "12px",labelIdLength: 30, alignmentHeight: 620, residueFont: "36px mono", labelFontsize: "22px", labelLineHeight: "42px", markerFontsize: "14px", columnWidth: 40, rowHeight: 40, menuFontsize: "28px", menuPadding: "5px 10px 5px 10px",menuMarginLeft: "10px", menuItemFontsize: "22px", menuItemLineHeight: "25px"}
var m = new msa.msa(opts);
m.el.style.marginTop = "10px";

// the menu is independent to the MSA container
var menuOpts = {};
var menuDiv = document.createElement('div');
document.body.appendChild(menuDiv);
menuOpts.el = menuDiv;
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);

m.addView("menu", defMenu);

m.render();
defMenu.el.style.marginTop = "15px";
defMenu.el.style.marginBottom = "25px";

});
