const view = require("backbone-viewj");
const dom = require("dom-helper");
import * as svg from "../../utils/svg";

const ConservationView = view.extend({

  className: "biojs_msa_conserv",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo(this.g.zoomer,"change:stepSize change:labelWidth change:columnWidth", this.render);
    this.listenTo(this.g.vis,"change:labels change:metacell", this.render);
    this.listenTo(this.g.columns, "change:scaling", this.render);
    // we need to wait until stats gives us the ok
    //@listenTo @model, "reset",@render
    this.listenTo(this.g.stats,"reset", this.render);

    var opts = _.extend( {}, {
      fillColor: ['#660', '#ff0'],
      strokeColor: '#330',
      maxHeight: 20,
      rectStyler: function(rect, data) { return rect }
    }, this.g.conservationConfig );

    this.fillColor = opts.fillColor;
    this.strokeColor = opts.strokeColor;
    this.maxHeight = opts.maxHeight;
    this.rectStyler = opts.rectStyler;

    return this.manageEvents();
  },

  // returns a function that will decide a colour
  // based on the conservation data it is given
  colorer: function(colorRange) {
    let colorer = function() { return "none" };

    if( typeof colorRange === 'string' ) {
      colorer = function() { return colorRange };
    }
    else if( Array.isArray( colorRange ) ) {
      if ( colorRange.length != 2 ) {
        console.error( "ERROR: colorRange array should have exactly two elements", colorRange );
      }

      // d3 is shipped modular nowadays - we can support both
      const d3BundledScale = (typeof d3 != "undefined" && !!d3.scale);
      const d3SeperatedScale = (typeof d3_scale != "undefined");
      if (!(d3BundledScale || d3SeperatedScale)) {
        console.warn( "providing a [min/max] range as input requires d3 to be included - only using the first color" );
        colorer = function(d) { return colorRange[0] };
      }
      else {
        const d3LinearScale = d3BundledScale ? d3.scale.linear() : d3_scale.scaleLinear();
        const scale = d3LinearScale
          .domain( [0, this.maxHeight] )
          .range(colorRange);

        colorer = function(d) { return scale(d.height) };
      }
    }
    else {
      console.warn( "expected colorRange to be '#rgb' or ['#rgb', '#rgb']", colorRange, '(' + typeof colorRange + ')' );
    }
    return colorer;
  },

  render: function() {
    var conserv = this.g.stats.scale(this.g.stats.conservation());

    dom.removeAllChilds(this.el);

    var nMax = this.model.getMaxLength();
    var cellWidth = this.g.zoomer.get("columnWidth");
    var maxHeight = this.maxHeight;
    var width = cellWidth * (nMax - this.g.columns.get('hidden').length);

    var s = svg.base({height: maxHeight, width: width});
    s.style.display = "inline-block";
    s.style.cursor = "pointer";

    var rectData = this.rectData;
    var fillColorer = this.colorer( this.fillColor );
    var strokeColorer = this.colorer( this.strokeColor );
    var rectStyler = this.rectStyler;

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
        avgHeight += conserv[n];
      }
      var height = maxHeight *  (avgHeight / stepSize);

      var d = {
        x: x,
        y: maxHeight - height,
        maxheight: maxHeight,
        width: width - cellWidth / 4,
        height: height,
        rowPos: n,
      };

      var rect = svg.rect( d );

      rect.style.stroke = strokeColorer(d);
      rect.style.fill = fillColorer(d);

      if ( typeof rectStyler === 'function' ) {
        rectStyler( rect, d );
      }

      rect.rowPos = n;

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
        result.push(this.g.trigger("bar:click", {rowPos: rowPos + i, evt:evt}));
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
    return this.g.trigger("bar:mousein", {rowPos: rowPos, evt:evt});
  },

  _onmouseout: function(evt) {
    var rowPos = this.g.zoomer.get("stepSize" * evt.rowPos);
    return this.g.trigger("bar:mouseout", {rowPos: rowPos, evt:evt});
  }
});

export default ConservationView;
