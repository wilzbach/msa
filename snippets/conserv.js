/* global rootDiv */
var msa = window.msa;
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  vis: {
    conserv: true,
  },
  conserv: {
    maxHeight: 200,
    fillColor: 'blue',
    strokeColor: '#000',
    rectStyler: function (rect, data) { 
      if ( data.rowPos < 10 ) {
        rect.style.fill = "red" 
      } 
    }
  }
};
var m = new msa(opts);
//@biojs-instance=m.g
