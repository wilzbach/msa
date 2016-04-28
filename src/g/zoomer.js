var Zoomer;
var Model = require("backbone-thin").Model;
// pixel properties for some components
module.exports = Zoomer = Model.extend({

  constructor: function(attributes,options) {
    this.calcDefaults(options.model);
    Model.apply(this, arguments);
    this.g = options.g;

    // events
    this.listenTo( this, "change:labelIdLength change:labelNameLength change:labelPartLength change:labelCheckLength", (function() {
      return this.trigger("change:labelWidth", this.getLabelWidth());
    }), this
    );
    this.listenTo( this, "change:metaLinksWidth change:metaIdentWidth change:metaGapWidth", (function() {
      return this.trigger("change:metaWidth", this.getMetaWidth());
    }), this
    );

    return this;
  },

  defaults: {

    // general
    alignmentWidth: "auto",
    alignmentHeight: 225,
    columnWidth: 15,
    rowHeight: 15,
    autoResize: true, // only for the width

    // labels
    textVisible: true,
    labelIdLength: 20,
    labelNameLength: 100,
    labelPartLength: 15,
    labelCheckLength: 15,
    labelFontsize: 13,
    labelLineHeight: "13px",

    // marker
    markerFontsize: "10px",
    stepSize: 1,
    markerStepSize: 2,
    markerHeight: 20,

    // canvas
    residueFont: "13", // in px
    canvasEventScale: 1,

    // overview box
    boxRectHeight: 2,
    boxRectWidth: 2,
    overviewboxPaddingTop: 10,

    // meta cell
    metaGapWidth: 35,
    metaIdentWidth: 40,
    // metaLinksWidth: 25

    // internal props
    _alignmentScrollLeft: 0,
    _alignmentScrollTop: 0
    },

  // sets some defaults, depending on the model
  calcDefaults: function(model) {
    var maxLen = model.getMaxLength();
    if (maxLen < 200 && model.length < 30) {
      return this.defaults.boxRectWidth = this.defaults.boxRectHeight = 5;
    }
  },

  // @param n [int] maxLength of all seqs
  getAlignmentWidth: function(n) {
    if (this.get("autoResize") && n !== undefined) {
      return this.get("columnWidth") * n;
    }
    if (this.get("alignmentWidth") === undefined || this.get("alignmentWidth") === "auto" || this.get("alignmentWidth") === 0) {
      return this._adjustWidth();
    } else {
      return this.get("alignmentWidth");
    }
  },

  // @param n [int] number of residues to scroll to the right
  setLeftOffset: function(n) {
    var val = (n);
    val = Math.max(0, val);
    val -= this.g.columns.calcHiddenColumns(val);
    return this.set("_alignmentScrollLeft", val * this.get('columnWidth'));
  },

  // @param n [int] row that should be on top
  setTopOffset: function(n) {
    var val = Math.max(0, (n - 1));
    var height = 0;
    for (var i = 0; 0 < val ? i <= val : i >= val; 0 < val ? i++ : i--) {
      var seq = this.model.at(i);
      height += seq.attributes.height || 1;
    }
    return this.set("_alignmentScrollTop",height * this.get("rowHeight"));
  },

  // length of all elements left to the main sequence body: labels, metacell, ..
  getLeftBlockWidth: function() {
     var paddingLeft = 0;
     if (this.g.vis.get("labels")) { paddingLeft += this.getLabelWidth(); }
     if (this.g.vis.get("metacell")) { paddingLeft += this.getMetaWidth(); }
     //paddingLeft += 15 # scroll bar
     return paddingLeft;
  },

  getMetaWidth: function() {
     var val = 0;
     if (this.g.vis.get("metaGaps")) { val += this.get("metaGapWidth"); }
     if (this.g.vis.get("metaIdentity")) { val += this.get("metaIdentWidth"); }
     if (this.g.vis.get("metaLinks")) { val += this.get("metaLinksWidth"); }
     return val;
  },

  getLabelWidth: function() {
     var val = 0;
     if (this.g.vis.get("labelName")) { val += this.get("labelNameLength"); }
     if (this.g.vis.get("labelId")) { val += this.get("labelIdLength"); }
     if (this.g.vis.get("labelPartition")) { val += this.get("labelPartLength"); }
     if (this.g.vis.get("labelCheckbox")) { val += this.get("labelCheckLength"); }
     return val;
  },

  _adjustWidth: function() {
    if (!(this.el !== undefined && this.model !== undefined)) { return; }
    if ((this.el.parentNode != null) && this.el.parentNode.offsetWidth !== 0) {
      var parentWidth = this.el.parentNode.offsetWidth;
    } else {
      parentWidth = document.body.clientWidth - 35;
    }

    // TODO: dirty hack
    var maxWidth = parentWidth - this.getLeftBlockWidth();
    var calcWidth = this.getAlignmentWidth( this.model.getMaxLength() - this.g.columns.get('hidden').length);
    var val = Math.min(maxWidth,calcWidth);
    // round to a valid AA box
    val = Math.floor( val / this.get("columnWidth")) * this.get("columnWidth");

    //@set "alignmentWidth", val
    return this.attributes.alignmentWidth = val;
  },

  autoResize: function() {
    if (this.get("autoResize")) {
      return this._adjustWidth(this.el, this.model);
    }
  },

  // max is the maximal allowed height
  autoHeight: function(max) {
    // TODO!
    // make seqlogo height configurable
    var val = this.getMaxAlignmentHeight();
    if (max !== undefined && max > 0) {
      val = Math.min(val, max);
    }

    return this.set("alignmentHeight", val);
  },

  setEl: function(el, model) {
    this.el = el;
    return this.model = model;
  },

  // updates both scroll properties (if needed)
  _checkScrolling: function(scrollObj, opts) {
    var xScroll = scrollObj[0];
    var yScroll = scrollObj[1];

    this.set("_alignmentScrollLeft", xScroll, opts);
    return this.set("_alignmentScrollTop", yScroll, opts);
  },

  getMaxAlignmentHeight: function() {
    var height = 0;
    this.model.each(function(seq) {
      return height += seq.attributes.height || 1;
    });

    return (height * this.get("rowHeight"));
  },

  getMaxAlignmentWidth: function() {
    return this.model.getMaxLength() * this.get("columnWidth");
  }
});

