const view = require("backbone-viewj");
const dom = require("dom-helper");
const jbone = require("jbone");
import * as svg from "../../utils/svg";

const MarkerView = view.extend({

  className: "biojs_msa_marker",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:stepSize change:labelWidth change:columnWidth change:markerStepSize change:markerFontsize", this.render);
    this.listenTo(this.g.vis,"change:labels change:metacell", this.render);
    return this.manageEvents();
  },

  render: function() {
    dom.removeAllChilds(this.el);

    const fontSize = this.g.zoomer.get("markerFontsize");
    const cellWidth = this.g.zoomer.get("columnWidth");
    const stepSize = this.g.zoomer.get("stepSize");
    const markerStepSize = this.g.zoomer.get("markerStepSize");

    const hidden = this.g.columns.get("hidden");

    this.el.style.fontSize = fontSize;

    const container = document.createElement("span");
    const nMax = this.model.getMaxLength();

    for( let n=0; n < nMax; n++ ) {
      if (hidden.indexOf(n) >= 0) {
        let el = this.markerHidden(n, stepSize);
        if (!!el)
            container.appendChild(el);
        n += stepSize;
        continue;
      }
      let span = document.createElement("span");
      span.className = 'msa-col-header';
      span.style.width = cellWidth + "px";
      span.style.display = "inline-block";

      if ((n+1) % markerStepSize === 0) {
        span.textContent = (n + 1);
      } else if ((n+1) % stepSize === 0) {
        span.textContent = ".";
      } else {
        span.textContent = " ";
      }
      span.rowPos = n;
      container.appendChild(span);
    }

    this.el.appendChild(container);
    return this;
  },

  markerHidden: function(n,stepSize) {
    const hidden = this.g.columns.get("hidden").slice(0);

    const min = Math.max(0, n - stepSize);
    let prevHidden = true;
    for (let j = min; j <= n; j++ ) {
      prevHidden &= hidden.indexOf(j) >= 0;
    }

    // filter duplicates
    if (prevHidden) { return; }

    const nMax = this.model.getMaxLength();

    let length = 0;
    let index = -1;
    // accumlate multiple rows
    for (let n2 = n; n2 <= nMax; n2++) {
      if (!(index >= 0)) { index = hidden.indexOf(n2); }// sets the first index
      if (hidden.indexOf(n2) >= 0) {
        length++;
      } else {
        break;
      }
    }

    const s = svg.base({height: 10, width: 10});
    s.style.position = "relative";
    const triangle = svg.polygon({points: "0,0 5,5 10,0", style:
      "fill:lime;stroke:purple;stroke-width:1"
    });
    jbone(triangle).on("click", (evt) => {
      hidden.splice(index, length);
      return this.g.columns.set("hidden", hidden);
    });

    s.appendChild(triangle);
    return s;
  },

  manageEvents: function() {
    const events = {};
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
    const rowPos = evt.target.rowPos;
    const stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:click", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  },

  _onmousein: function(evt) {
    const rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    const stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:mousein", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  },

  _onmouseout: function(evt) {
    const rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    const stepSize = this.g.zoomer.get("stepSize");
    return this.g.trigger("column:mouseout", {rowPos: rowPos,stepSize: stepSize, evt:evt});
  }
});

export default MarkerView;
