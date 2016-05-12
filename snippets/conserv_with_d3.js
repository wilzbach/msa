
var maxheight = 200;

var scale = d3.scale.linear()
  .domain([0, maxheight / 2, maxheight])
  .range(['#f00', '#ff0', '#0f0']);

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
    fillColor: ['blue', '#0f0'],
    strokeColor: '#000',
    rectStyler: function (rect, data) { 
      rect.style.fill = scale(data.height);
    }
  }
};
var m = new msa(opts);
//@biojs-instance=m.g
