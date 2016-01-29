var boneView = require("backbone-childs");
var mouse = require("mouse-pos");
var _ = require("underscore");
var jbone = require("jbone");
var CharCache = require("./CanvasCharCache");
var SelectionClass = require("./CanvasSelection");
var CanvasSeqDrawer = require("./CanvasSeqDrawer");
var CanvasCoordsCache = require("./CanvasCoordsCache");

module.exports = boneView.extend({

  tagName: "canvas",

  initialize: function(data) {
    this.g = data.g;

    this.listenTo(this.g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", function(model,value, options) {
      if ((!(((typeof options !== "undefined" && options !== null) ? options.origin : undefined) != null)) || options.origin !== "canvasseq") {
        return this.render();
      }
    });

    this.listenTo(this.g.columns,"change:hidden", this.render);
    this.listenTo(this.g.zoomer,"change:alignmentWidth change:alignmentHeight", this.render);
    this.listenTo(this.g.colorscheme, "change", this.render);
    this.listenTo(this.g.selcol, "reset add", this.render);
    this.listenTo(this.model, "reset add", this.render);

    // el props
    this.el.style.display = "inline-block";
    this.el.style.overflowX = "hidden";
    this.el.style.overflowY = "hidden";
    this.el.className = "biojs_msa_seqblock";

    this.ctx = this.el.getContext('2d');
    this.cache = new CharCache(this.g);
    this.coordsCache = new CanvasCoordsCache(this.g, this.model);

    // clear the char cache
    this.listenTo(this.g.zoomer, "change:residueFont", function() {
      this.cache = new CharCache(this.g);
      return this.render();
    });

    // init selection
    this.sel = new SelectionClass(this.g,this.ctx);

    this._setColor();

    // throttle the expensive draw function
    this.throttleTime = 0;
    this.throttleCounts = 0;
    if ((document.documentElement.style.webkitAppearance != null)) {
      // webkit browser - no throttling needed
      this.throttledDraw = function() {
        var start = +new Date();
        this.draw();
        this.throttleTime += +new Date() - start;
        this.throttleCounts++;
        if (this.throttleCounts > 15) {
          var tTime = Math.ceil(this.throttleTime / this.throttleCounts);
          console.log("avgDrawTime/WebKit", tTime);
          // remove perf analyser
          return this.throttledDraw = this.draw;
        }
      };
    } else {
      // slow browsers like Gecko
      this.throttledDraw = _.throttle(this.throttledDraw, 30);
    }

    return this.manageEvents();
  },


  // measures the time of a redraw and thus set the throttle limit
  throttledDraw: function() {
    // +new is the fastest: http://jsperf.com/new-date-vs-date-now-vs-performance-now/6
    var start = +new Date();
    this.draw();
    this.throttleTime += +new Date() - start;
    this.throttleCounts++;

    // remove itself after analysis
    if (this.throttleCounts > 15) {
      var tTime = Math.ceil(this.throttleTime / this.throttleCounts);
      console.log("avgDrawTime", tTime);
      tTime *=  1.2; // add safety time
      tTime = Math.max(20, tTime); // limit for ultra fast computers
      return this.throttledDraw = _.throttle(this.draw, tTime);
    }
  },

  manageEvents: function() {
    var events = {};
    events.mousedown = "_onmousedown";
    events.touchstart = "_ontouchstart";

    if (this.g.config.get("registerMouseClicks")) {
      events.dblclick = "_onclick";
    }
    if (this.g.config.get("registerMouseHover")) {
      events.mousein = "_onmousein";
      events.mouseout = "_onmouseout";
    }

    events.mousewheel = "_onmousewheel";
    events.DOMMouseScroll = "_onmousewheel";
    this.delegateEvents(events);

    // listen for changes
    this.listenTo(this.g.config, "change:registerMouseHover", this.manageEvents);
    this.listenTo(this.g.config, "change:registerMouseClick", this.manageEvents);
    return this.dragStart = [];
  },

  _setColor: function() {
    return this.color = this.g.colorscheme.getSelectedScheme();
  },

  draw: function() {
    // fastest way to clear the canvas
    // http://jsperf.com/canvas-clear-speed/25
    this.el.width = this.el.width;

    // draw all the stuff
    if ((this.seqDrawer != null)  && this.model.length > 0) {
      // char based
      this.seqDrawer.drawLetters();
      // row based
      this.seqDrawer.drawRows(this.sel._appendSelection, this.sel);
      return this.seqDrawer.drawRows(this.drawFeatures, this);
    }
  },

  drawFeatures: function(data) {
    var rectWidth = this.g.zoomer.get("columnWidth");
    var rectHeight = this.g.zoomer.get("rowHeight");
    if (data.model.attributes.height > 1) {
      var ctx = this.ctx;
      data.model.attributes.features.each(function(feature) {
        ctx.fillStyle = feature.attributes.fillColor || "red";
        var len = feature.attributes.xEnd - feature.attributes.xStart + 1;
        var y = (feature.attributes.row + 1) * rectHeight;
        return ctx.fillRect(feature.attributes.xStart * rectWidth + data.xZero,y + data.yZero,rectWidth * len,rectHeight);
      });

      // draw text
      ctx.fillStyle = "black";
      ctx.font = this.g.zoomer.get("residueFont") + "px mono";
      ctx.textBaseline = 'middle';
      ctx.textAlign = "center";

      return data.model.attributes.features.each(function(feature) {
        var len = feature.attributes.xEnd - feature.attributes.xStart + 1;
        var y = (feature.attributes.row + 1) * rectHeight;
        return ctx.fillText( feature.attributes.text, data.xZero + feature.attributes.xStart *
        rectWidth + (len / 2) * rectWidth, data.yZero + rectHeight * 0.5 + y
        );
      });
    }
  },

  render: function() {

    this.el.setAttribute('height', this.g.zoomer.get("alignmentHeight") + "px");
    this.el.setAttribute('width', this.g.zoomer.getAlignmentWidth() + "px");

    this.g.zoomer._checkScrolling( this._checkScrolling([this.g.zoomer.get('_alignmentScrollLeft'),
    this.g.zoomer.get('_alignmentScrollTop')] ),{header: "canvasseq"});

    this._setColor();

    this.seqDrawer = new CanvasSeqDrawer( this.g,this.ctx,this.model,
      {width: this.el.width,
      height: this.el.height,
      color: this.color,
      cache: this.cache
    });

    this.throttledDraw();
    return this;
  },

  _onmousemove: function(e, reversed) {
    if (this.dragStart.length === 0) { return; }

    var dragEnd = mouse.abs(e);
    // relative to first click
    var relEnd = [dragEnd[0] - this.dragStart[0], dragEnd[1] - this.dragStart[1]];
    // relative to initial scroll status

    // scale events
    var scaleFactor = this.g.zoomer.get("canvasEventScale");
    if (reversed) {
      scaleFactor = 3;
    }
    for (var i = 0; i <= 1; i++) {
      relEnd[i] = relEnd[i] * scaleFactor;
    }

    // calculate new scrolling vals
    var relDist = [this.dragStartScroll[0] - relEnd[0], this.dragStartScroll[1] - relEnd[1]];

    // round values
    for (var i = 0; i <= 1; i++) {
      relDist[i] = Math.round(relDist[i]);
    }

    // update scrollbar
    var scrollCorrected = this._checkScrolling( relDist);
    this.g.zoomer._checkScrolling(scrollCorrected, {origin: "canvasseq"});

    // reset start if use scrolls out of bounds
    for (var i = 0; i <= 1; i++) {
      if (scrollCorrected[i] !== relDist[i]) {
        if (scrollCorrected[i] === 0) {
          // reset of left, top
          this.dragStart[i] = dragEnd[i];
          this.dragStartScroll[i] = 0;
        } else {
          // recalibrate on right, bottom
          this.dragStart[i] = dragEnd[i] - scrollCorrected[i];
        }
      }
    }

    this.throttledDraw();

    // abort selection events of the browser (mouse only)
    if ((e.preventDefault != null)) {
      e.preventDefault();
      return e.stopPropagation();
    }
  },

  // converts touches into old mouse event
  _ontouchmove: function(e) {
    this._onmousemove(e.changedTouches[0], true);
    e.preventDefault();
    return e.stopPropagation();
  },

  // start the dragging mode
  _onmousedown: function(e) {
    this.dragStart = mouse.abs(e);
    this.dragStartScroll = [this.g.zoomer.get('_alignmentScrollLeft'), this.g.zoomer.get('_alignmentScrollTop')];
    jbone(document.body).on('mousemove.overmove', (e) => this._onmousemove(e));
    jbone(document.body).on('mouseup.overup', () => this._cleanup());
    //jbone(document.body).on 'mouseout.overout', (e) => @_onmousewinout(e)
    return e.preventDefault();
  },

  // starts the touch mode
  _ontouchstart: function(e) {
    this.dragStart = mouse.abs(e.changedTouches[0]);
    this.dragStartScroll = [this.g.zoomer.get('_alignmentScrollLeft'), this.g.zoomer.get('_alignmentScrollTop')];
    jbone(document.body).on('touchmove.overtmove', (e) => this._ontouchmove(e));
    return jbone(document.body).on( 'touchend.overtend touchleave.overtleave touchcancel.overtcanel', (e) => this._touchCleanup(e)
    );
  },

  // checks whether mouse moved out of the window
  // -> terminate dragging
  _onmousewinout: function(e) {
    if (e.toElement === document.body.parentNode) {
      return this._cleanup();
    }
  },

  // terminates dragging
  _cleanup: function() {
    this.dragStart = [];
    // remove all listeners
    jbone(document.body).off('.overmove');
    jbone(document.body).off('.overup');
    return jbone(document.body).off('.overout');
  },

  // terminates touching
  _touchCleanup: function(e) {
    if (e.changedTouches.length > 0) {
      // maybe we can send a final event
      this._onmousemove(e.changedTouches[0], true);
    }

    this.dragStart = [];
    // remove all listeners
    jbone(document.body).off('.overtmove');
    jbone(document.body).off('.overtend');
    jbone(document.body).off('.overtleave');
    return jbone(document.body).off('.overtcancel');
  },

  // might be incompatible with some browsers
  _onmousewheel: function(e) {
    var delta = mouse.wheelDelta(e);
    this.g.zoomer.set('_alignmentScrollLeft', this.g.zoomer.get('_alignmentScrollLeft') + delta[0]);
    this.g.zoomer.set('_alignmentScrollTop', this.g.zoomer.get('_alignmentScrollTop') + delta[1]);
    return e.preventDefault();
  },

  _onclick: function(e) {
    var res = this._getClickPos(e);
    if ((typeof res !== "undefined" && res !== null)) {
      if ((res.feature != null)) {
        this.g.trigger("feature:click", res);
      } else {
        this.g.trigger("residue:click", res);
      }
    }
    return this.throttledDraw();
  },

  _onmousein: function(e) {
    var res = this._getClickPos(e);
    if ((typeof res !== "undefined" && res !== null)) {
      if ((res.feature != null)) {
        this.g.trigger("feature:mousein", res);
      } else {
        this.g.trigger("residue:mousein", res);
      }
    }
    return this.throttledDraw();
  },

  _onmouseout: function(e) {
    var res = this._getClickPos(e);
    if ((typeof res !== "undefined" && res !== null)) {
      if ((res.feature != null)) {
        this.g.trigger("feature:mouseout", res);
      } else {
        this.g.trigger("residue:mouseout", res);
      }
    }

    return this.throttledDraw();
  },

  _getClickPos: function(e) {
    var coords = mouse.rel(e);

    coords[0] += this.g.zoomer.get("_alignmentScrollLeft");
    var x = Math.floor(coords[0] / this.g.zoomer.get("columnWidth") );
    var [y,rowNumber] = this.seqDrawer._getSeqForYClick(coords[1]);

    // add hidden columns
    x += this.g.columns.calcHiddenColumns(x);
    // add hidden seqs
    y += this.model.calcHiddenSeqs(y);

    x = Math.max(0,x);
    y = Math.max(0,y);

    var seqId = this.model.at(y).get("id");

    if (rowNumber > 0) {
      // click on a feature
      var features = this.model.at(y).get("features").getFeatureOnRow(rowNumber - 1, x);
      if (!(features.length === 0)) {
        var feature = features[0];
        console.log(features[0].attributes);
        return {seqId:seqId, feature: feature, rowPos: x, evt:e};
      }
    } else {
      // click on a seq
      return {seqId:seqId, rowPos: x, evt:e};
    }
  },

  // checks whether the scrolling coordinates are valid
  // @returns: [xScroll,yScroll] valid coordinates
  _checkScrolling: function(scrollObj) {

    // 0: maxLeft, 1: maxTop
    var max = [this.coordsCache.maxScrollWidth, this.coordsCache.maxScrollHeight];

    for (var i = 0; i <= 1; i++) {
      if (scrollObj[i] > max[i]) {
        scrollObj[i] = max[i];
      }

      if (scrollObj[i] < 0) {
        scrollObj[i] = 0;
      }
    }

    return scrollObj;
  }
});
