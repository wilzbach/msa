var OverviewBox;
var view = require("backbone-viewj");
var mouse = require("mouse-pos");
var selection = require("../g/selection/Selection");
var jbone = require("jbone");
var _ = require("underscore");

module.exports = OverviewBox = view.extend({

  className: "biojs_msa_overviewbox",
  tagName: "canvas",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo( this.g.zoomer,"change:boxRectWidth change:boxRectHeight change:overviewboxPaddingTop", this.rerender);
    this.listenTo(this.g.selcol, "add reset change", this.rerender);
    this.listenTo(this.g.columns, "change:hidden", this.rerender);
    this.listenTo(this.g.colorscheme, "change:showLowerCase", this.rerender);
    this.listenTo(this.model, "change", _.debounce(this.rerender, 5));

    // color
    this.color = this.g.colorscheme.getSelectedScheme();
    this.listenTo(this.g.colorscheme, "change:scheme", function() {
      this.color = this.g.colorscheme.getSelectedScheme();
      return this.rerender();
    });
    return this.dragStart = [];
  },

  events:
    {click: "_onclick",
    mousedown: "_onmousedown"
    },

  rerender: function() {
    if (!this.g.config.get("manualRendering")) {
      return this.render();
    }
  },

  render: function() {
    this._createCanvas();
    this.el.textContent = "overview";
    this.el.style.marginTop = this.g.zoomer.get("overviewboxPaddingTop");

    // background bg for non-drawed area
    this.ctx.fillStyle = "#999999";
    this.ctx.fillRect(0,0,this.el.width,this.el.height);

    var rectWidth = this.g.zoomer.get("boxRectWidth");
    var rectHeight = this.g.zoomer.get("boxRectHeight");
    var hidden = this.g.columns.get("hidden");
    var showLowerCase = this.g.colorscheme.get("showLowerCase");

    var y = -rectHeight;
    var end = this.model.length - 1;
    for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      var seq = this.model.at(i).get("seq");
      var x = 0;
      y = y + rectHeight;


      if (this.model.at(i).get("hidden")) {
        // hidden seq
        console.log(this.model.at(i).get("hidden"));
        this.ctx.fillStyle = "grey";
        this.ctx.fillRect(0,y,seq.length * rectWidth,rectHeight);
        continue;
      }

      var end1 = seq.length - 1;
      for (var j = 0; 0 < end1 ? j <= end1 : j >= end1; 0 < end1 ? j++ : j--) {
        var c = seq[j];
        // todo: optional uppercasing
        if (showLowerCase) { c = c.toUpperCase(); }
        var color = this.color.getColor(c, {pos: j});

        if (hidden.indexOf(j) >= 0) {
          color = "grey";
        }

        if ((typeof color !== "undefined" && color !== null)) {
          this.ctx.fillStyle = color;
          this.ctx.fillRect(x,y,rectWidth,rectHeight);
        }

        x = x + rectWidth;
      }
    }

    return this._drawSelection();
  },

  _drawSelection: function() {
    // hide during selection
    if (this.dragStart.length > 0 && !this.prolongSelection) { return; }

    var rectWidth = this.g.zoomer.get("boxRectWidth");
    var rectHeight = this.g.zoomer.get("boxRectHeight");
    var maxHeight = rectHeight * this.model.length;
    this.ctx.fillStyle = "#666666";
    this.ctx.globalAlpha = 0.9;
    var end = this.g.selcol.length - 1;
    for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
      var sel = this.g.selcol.at(i);
      if(!sel) continue;
      if (sel.get('type') === 'column') {
        this.ctx.fillRect( rectWidth * sel.get('xStart'),0,rectWidth *
        (sel.get('xEnd') - sel.get('xStart') + 1),maxHeight
        );
      } else if (sel.get('type') === 'row') {
        var seq = (this.model.filter(function(el) { return el.get('id') === sel.get('seqId'); }))[0];
        var pos = this.model.indexOf(seq);
        this.ctx.fillRect(0,rectHeight * pos, rectWidth * seq.get('seq').length, rectHeight);
      } else if (sel.get('type') === 'pos') {
        seq = (this.model.filter(function(el) { return el.get('id') === sel.get('seqId'); }))[0];
        pos = this.model.indexOf(seq);
        this.ctx.fillRect(rectWidth * sel.get('xStart'),rectHeight * pos, rectWidth * (sel.get('xEnd') - sel.get('xStart') + 1), rectHeight);
      }
    }

    return this.ctx.globalAlpha = 1;
  },

  _onclick: function(evt) {
    return this.g.trigger("meta:click", {seqId: this.model.get("id", {evt:evt})});
  },

  _onmousemove: function(e) {
    // duplicate events
    if (this.dragStart.length === 0) { return; }

    this.render();
    this.ctx.fillStyle = "#666666";
    this.ctx.globalAlpha = 0.9;

    var rect = this._calcSelection( mouse.abs(e) );
    this.ctx.fillRect(rect[0][0],rect[1][0],rect[0][1] - rect[0][0], rect[1][1] - rect[1][0]);

    // abort selection events of the browser
    e.preventDefault();
    return e.stopPropagation();
  },

  // start the selection mode
  _onmousedown: function(e) {
    this.dragStart = mouse.abs(e);
    this.dragStartRel = mouse.rel(e);

    if (e.ctrlKey || e.metaKey) {
      this.prolongSelection = true;
    } else {
      this.prolongSelection = false;
    }
    // enable global listeners
    jbone(document.body).on('mousemove.overmove', (e) => this._onmousemove(e));
    jbone(document.body).on('mouseup.overup', (e) => this._onmouseup(e));
    return this.dragStart;
  },

  // calculates the current selection
  _calcSelection: function(dragMove) {
    // relative to first click
    var dragRel = [dragMove[0] - this.dragStart[0], dragMove[1] - this.dragStart[1]];

    // relative to target
    for (var i = 0; i <= 1; i++) {
      dragRel[i] = this.dragStartRel[i] + dragRel[i];
    }

    // 0:x, 1: y
    var rect = [[this.dragStartRel[0], dragRel[0]], [this.dragStartRel[1], dragRel[1]]];

    // swap the coordinates if needed
    for (var i = 0; i <= 1; i++) {
      if (rect[i][1] < rect[i][0]) {
        rect[i] = [rect[i][1], rect[i][0]];
      }

      // lower limit
      rect[i][0] = Math.max(rect[i][0], 0);
    }

    return rect;
  },

  _endSelection: function(dragEnd) {
    // remove listeners
    jbone(document.body).off('.overmove');
    jbone(document.body).off('.overup');

    // duplicate events
    if (this.dragStart.length === 0) { return; }

    var rect = this._calcSelection(dragEnd);

    // x
    for (var i = 0; i <= 1; i++) {
      rect[0][i] = Math.floor( rect[0][i] / this.g.zoomer.get("boxRectWidth"));
    }

    // y
    for (var i = 0; i <= 1; i++) {
      rect[1][i] = Math.floor( rect[1][i] / this.g.zoomer.get("boxRectHeight") );
    }

    // upper limit
    rect[0][1] = Math.min(this.model.getMaxLength() - 1, rect[0][1]);
    rect[1][1] = Math.min(this.model.length - 1, rect[1][1]);

    // select
    var selis = [];
    for (var j = rect[1][0]; rect[1][0] < rect[1][1] ? j <= rect[1][1] : j >= rect[1][1]; rect[1][0] < rect[1][1] ? j++ : j--) {
      var args = {seqId: this.model.at(j).get('id'), xStart: rect[0][0], xEnd: rect[0][1]};
      selis.push(new selection.possel(args));
    }

    // reset
    this.dragStart = [];
    // look for ctrl key
    if (this.prolongSelection) {
      this.g.selcol.add(selis);
    } else {
      this.g.selcol.reset(selis);
    }

    // safety check + update offset
    this.g.zoomer.setLeftOffset(rect[0][0]);
    return this.g.zoomer.setTopOffset(rect[1][0]);
  },

  // ends the selection mode
  _onmouseup: function(e) {
    return this._endSelection(mouse.abs(e));
  },

  _onmouseout: function(e) {
    return this._endSelection(mouse.abs(e));
  },

 // init the canvas
  _createCanvas: function() {
    var rectWidth = this.g.zoomer.get("boxRectWidth");
    var rectHeight = this.g.zoomer.get("boxRectHeight");

    this.el.height = this.model.length * rectHeight;
    this.el.width = this.model.getMaxLength() * rectWidth;
    this.ctx = this.el.getContext("2d");
    this.el.style.overflow = "scroll";
    return this.el.style.cursor = "crosshair";
  }
});
