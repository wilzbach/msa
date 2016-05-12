var maxHeight = 200;

var scale = d3_scale.scaleLinear()
  .domain([0, maxHeight / 2, maxHeight])
  .range(['#f00', '#ff0', '#0f0']);

/* global rootDiv */
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  vis: {
    conserv: true,
  },
  conserv: {
    maxHeight: maxHeight,
    strokeColor: '#000',
    rectStyler: function (rect, data) {
      if ( data.rowPos < 20 ) {
        rect.style.fill = scale(data.height);
      }
      return rect;
    }
  }
};
var m = new msa(opts);
//@biojs-instance=m.g
