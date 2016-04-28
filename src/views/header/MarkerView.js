var view = require("backbone-viewj");
var dom = require("dom-helper");
var svg = require("../../utils/svg");
var jbone = require("jbone");

var HeaderView = view.extend({

  className: "biojs_msa_marker",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:stepSize change:labelWidth change:columnWidth change:markerStepSize change:markerFontsize", this.render);
    this.listenTo(this.g.vis,"change:labels change:metacell", this.render);
    return this.manageEvents();
  },

  render: function() {
    dom.removeAllChilds(this.el);

    this.el.style.fontSize = this.g.zoomer.get("markerFontsize");

    var container = document.createElement("span");
    var n = 0;
    var cellWidth = this.g.zoomer.get("columnWidth");

    var nMax = this.model.getMaxLength();
    var stepSize = this.g.zoomer.get("stepSize");
    var hidden = this.g.columns.get("hidden");

    while (n < nMax) {
      if (hidden.indexOf(n) >= 0) {
        this.markerHidden(span,n, stepSize);
        n += stepSize;
        continue;
      }
      var span = document.createElement("span");
      span.style.width = (cellWidth * stepSize) + "px";
      span.style.display = "inline-block";
      // TODO: this doesn't work for a larger stepSize
      if ((n + 1) % this.g.zoomer.get('markerStepSize') === 0) {
        span.textContent = (n + 1);
      } else {
        span.textContent = ".";
      }
      span.rowPos = n;

      n += stepSize;
      container.appendChild(span);
    }

    this.el.appendChild(container);
    return this;
  },

  markerHidden: function(span,n,stepSize) {
    var hidden = this.g.columns.get("hidden").slice(0);

    var min = Math.max(0, n - stepSize);
    var prevHidden = true;
    for (var j = min; min < n ? j <= n : j >= n; min < n ? j++ : j--) {
      prevHidden &= hidden.indexOf(j) >= 0;
    }

    // filter duplicates
    if (prevHidden) { return; }

    var nMax = this.model.getMaxLength();

    var length = 0;
    var index = -1;
    // accumlate multiple rows
    for (var n = n; n < nMax ? n <= nMax : n >= nMax; n < nMax ? n++ : n--) {
      if (!(index >= 0)) { index = hidden.indexOf(n); }// sets the first index
      if (hidden.indexOf(n) >= 0) {
        length++;
      } else {
        break;
      }
    }

    var s = svg.base({height: 10, width: 10});
    s.style.position = "relative";
    var triangle = svg.polygon({points: "0,0 5,5 10,0", style:
      "fill:lime;stroke:purple;stroke-width:1"
    });jbone(triangle).on("click", (evt) => {
      hidden.splice(index, length);
      return this.g.columns.set("hidden", hidden);
    });

    s.appendChild(triangle);
    span.appendChild(s);
    return s;
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

  _onclick: function(evt) {
    var rowPos = evt.target.rowPos;
    var stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:click", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  },

  _onmousein: function(evt) {
    var rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    var stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:mousein", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  },

  _onmouseout: function(evt) {
    var rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    var stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:mouseout", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  }
});

module.exports = HeaderView;
