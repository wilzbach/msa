var maxHeight = 200;

// support both the modularized and standalone d3
var scaleLinear = (typeof d3 != "undefined") ? d3.scale.linear() : d3_scale.scaleLinear();
var scale = scaleLinear
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
