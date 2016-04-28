var view = require("backbone-viewj");
var dom = require("dom-helper");
var svg = require("../../utils/svg");

// TODO: merge this with the conservation view
var ConservationView = view.extend({

  className: "biojs_msa_gapview",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:stepSize change:labelWidth change:columnWidth", this.render);
    this.listenTo(this.g.vis,"change:labels change:metacell", this.render);
    this.listenTo(this.g.columns, "change:scaling", this.render);
    // we need to wait until stats gives us the ok
    this.listenTo(this.model, "reset",this.render);
    return this.manageEvents();
  },

  render: function() {
    var gaps = this.g.stats.gaps();

    dom.removeAllChilds(this.el);

    var nMax = this.model.getMaxLength();
    var cellWidth = this.g.zoomer.get("columnWidth");
    var maxHeight = 20;
    var width = cellWidth * (nMax - this.g.columns.get('hidden').length);

    var s = svg.base({height: maxHeight, width: width});
    s.style.display = "inline-block";
    s.style.cursor = "pointer";

    var stepSize = this.g.zoomer.get("stepSize");
    var hidden = this.g.columns.get("hidden");
    var x = 0;
    var n = 0;
    while (n < nMax) {
      if (hidden.indexOf(n) >= 0) {
        n += stepSize;
        continue;
      }
      width = cellWidth * stepSize;
      var avgHeight = 0;
      var end = stepSize - 1;
      for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
        avgHeight += gaps[n];
      }
      var height = maxHeight *  (avgHeight / stepSize);

      var rect =  svg.rect({x:x,y: maxHeight - height,width:width - cellWidth / 4,height:height,style:
        "stroke:red;stroke-width:1;"
      });rect.rowPos = n;
      s.appendChild(rect);
      x += width;
      n += stepSize;
    }

    this.el.appendChild(s);
    return this;
  },

  //TODO: make more general with HeaderView
  _onclick: function(evt) {
    var rowPos = evt.target.rowPos;
    var stepSize = this.g.zoomer.get("stepSize");
    // simulate hidden columns
    return (() => {
      var result = [];
      var end = stepSize - 1;
      for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
        result.push(this.g.trigger("gap:click", {rowPos: rowPos + i, evt:evt}));
      }
      return result;
    })();
  },

  manageEvents: function() {
    var events = {};
    if (this.g.config.get("registerMouseClicks")) {
      events.click = "_onclick";
    }
    if (this.g.config.get("registerMouseHover")) {
      events.mousein = "_onmousein";
      events.mouseout = "_onmouseout";
    }
    this.delegateEvents(events);
    this.listenTo(this.g.config, "change:registerMouseHover", this.manageEvents);
    return this.listenTo(this.g.config, "change:registerMouseClick", this.manageEvents);
  },

  _onmousein: function(evt) {
    var rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    return this.g.trigger("gap:mousein", {rowPos: rowPos, evt:evt});
  },

  _onmouseout: function(evt) {
    var rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    return this.g.trigger("gap:mouseout", {rowPos: rowPos, evt:evt});
  }
});

module.exports = ConservationView;
