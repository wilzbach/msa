var SeqLogoView = require("biojs-vis-seqlogo/light");
var view = require("backbone-viewj");
var dom = require("dom-helper");

// this is a bridge between the MSA and the seqlogo viewer
module.exports = view.extend({

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:alignmentWidth", this.render);
    this.listenTo(this.g.colorscheme, "change", function() {
      var colors = this.g.colorscheme.getSelectedScheme();
      this.seqlogo.changeColors(colors);
      return this.render();
    });

    this.listenTo(this.g.zoomer,"change:columnWidth", function() {
      this.seqlogo.column_width = this.g.zoomer.get('columnWidth');
      return this.render();
    });

    //@listenTo @g.zoomer,"change:columnWidth change:rowHeight", ->

    this.listenTo(this.g.stats, "reset", function() {
      this.draw();
      return this.render();
    });

    return this.draw();
  },


  draw: function() {
    dom.removeAllChilds(this.el);

    console.log("redraw seqlogo");
    var arr = this.g.stats.conservResidue({scaled: true});
    arr = _.map(arr, function(el) {
      return _.pick(el, function(e,k) {
        return k !== "-";
      });
    });
    var data =
      {alphabet: "aa",
      heightArr: arr
      };

    var colors = this.g.colorscheme.getSelectedScheme();
    // TODO: seqlogo might have problems with true dynamic schemes
    return this.seqlogo = new SeqLogoView({model: this.model, g: this.g, data: data, yaxis:false ,scroller: false,xaxis: false, height: 100, column_width: this.g.zoomer.get('columnWidth'),positionMarker: false, zoom: 1, el: this.el,colors: colors});
  },

  render: function() {
    return this.seqlogo.render();
  }
});
