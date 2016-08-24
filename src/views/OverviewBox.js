const view = require("backbone-viewj");
const mouse = require("mouse-pos");
const jbone = require("jbone");
import {possel} from "../g/selection/Selection";

const OverviewBox = view.extend({

  className: "biojs_msa_overviewbox",
  tagName: "canvas",

  initialize: function(data) {
    this.g = data.g;
    this.listenTo( this.g.zoomer,"change:boxRectWidth change:boxRectHeight change:overviewboxPaddingTop", this.rerender);
    this.listenTo(this.g.zoomer, "change:alignmentHeight change:alignmentWidth", this.rerender);
    this.listenTo(this.g.zoomer, "change:overviewboxWidth change:overviewboxHeigth", this.rerender);
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

    const len = this.model.length;
    const hidden = this.g.columns.get("hidden");
    const showLowerCase = this.g.colorscheme.get("showLowerCase");

    let y = -this.coords.boxes_size.y;
    for (let ybox=0; ybox < this.coords.boxes.y; ybox++) {
      const seqs = [];
      const seq_hidden = [];
      for (let i = Math.floor(ybox*this.coords.resid_per_box.y); 
               i < Math.floor((ybox+1)*this.coords.resid_per_box.y) && i < len; i++) {
        // fixes weird bug on tatyana's machine
        if (!this.model.at(i)){
          continue;
        }
        seqs.push(this.model.at(i).get("seq"));
        seq_hidden.push(this.model.at(i).get('hidden'));
      }
      let x = 0;
      y = y + this.coords.boxes_size.y;

      for (let xbox = 0; xbox < this.coords.boxes.x; xbox++){
        var colors = [];
        for (let i=0; i<seqs.length; i++) {
          for (let j=Math.floor(xbox*this.coords.resid_per_box.x); j<Math.floor((xbox+1)*this.coords.resid_per_box.x) && j<seqs[i].length; j++) {
            if (seq_hidden[i]) {
              colors.push("grey");
              continue;
            }
            let c = seqs[i][j];
            // todo: optional uppercasing
            if (showLowerCase) { c = c.toUpperCase(); }
            let color = this.color.getColor(c, {pos: j});
  
            if (hidden.indexOf(j) >= 0) {
              color = "grey";
            }
  
            if ((typeof color !== "undefined" && color !== null)) {
              colors.push(color);
            }
          }
        }
        
        if (colors.length !== 0) {
          this.ctx.fillStyle = this._mode(colors);
          this.ctx.fillRect(x, y, this.coords.boxes_size.x, this.coords.boxes_size.y);
        }

        x = x + this.coords.boxes_size.x;
      }
    }

    return this._drawSelection();
  },

  coords: {
    screen_to_model: function(val, coord){
      const pos = val * this.resid_per_box[coord] / this.boxes_size[coord];
      return Math.floor(pos)
    },
    model_to_screen: function(val, coord){
      return Math.floor(val * this.boxes_size[coord] / this.resid_per_box[coord]);
    },
    updatecoords_transform: function(overviewBox) {
      const rectHeight = overviewBox.g.zoomer.get('boxRectHeight');
      const rectWidth = overviewBox.g.zoomer.get('boxRectWidth');
      const setting_w = overviewBox.g.zoomer.get('overviewboxWidth');
      const setting_h = overviewBox.g.zoomer.get('overviewboxHeight');

      const contWidth = setting_w === "fixed" ? overviewBox.model.getMaxLength() * rectWidth :
                        Math.min(overviewBox.g.zoomer.get('alignmentWidth') + overviewBox.g.zoomer.getLeftBlockWidth(),
                                 overviewBox.model.getMaxLength() * rectWidth);
      const contHeight = setting_h === "fixed" ? overviewBox.model.length * rectHeight :
                         Math.min((isNaN(parseInt(setting_h, 10)) ? 1e10 : parseInt(setting_h,10)),
                                  overviewBox.model.length * rectHeight);
      
      this.container_size = {x: contWidth, y: contHeight};
      this.boxes_size = {x: rectWidth, y: rectHeight};
      this.resid_per_box = {x: Math.max(1, overviewBox.model.getMaxLength() / contWidth * rectWidth),
                            y: Math.max(1, overviewBox.model.length / contHeight * rectHeight)};
      this.boxes = {x: Math.ceil(contWidth / rectWidth),
                    y: Math.ceil(contHeight / rectHeight)};
    }
  },

  _mode: function(arr) {
    // get the mode, i.e. the most frequent element of an array
    return arr.sort((a,b) =>
              arr.filter(v => v===a).length
            - arr.filter(v => v===b).length
    ).pop();
  },

  _drawSelection: function() {
    // hide during selection
    if (this.dragStart.length > 0 && !this.prolongSelection) { return; }

    this.ctx.fillStyle = "#666666";
    this.ctx.globalAlpha = 0.9;
    const len = this.g.selcol.length;
    for (let i = 0; i < len; i++) {
      const sel = this.g.selcol.at(i);
      if(!sel) continue;
      let seq, pos;
      if (sel.get('type') === 'column') {
        this.ctx.fillRect( this.coords.boxes_size.x * sel.get('xStart'),0,this.coords.boxes_size.x *
        (sel.get('xEnd') - sel.get('xStart') + 1), this.coords.container_size.y
        );
      } else if (sel.get('type') === 'row') {
        seq = (this.model.filter(function(el) { return el.get('id') === sel.get('seqId'); }))[0];
        pos = this.model.indexOf(seq);
        this.ctx.fillRect(0, this.coords.model_to_screen(pos, 'y'), 
                          this.coords.model_to_screen(seq.get('seq').length, 'x'), this.coords.boxes_size.y);
      } else if (sel.get('type') === 'pos') {
        seq = (this.model.filter(function(el) { return el.get('id') === sel.get('seqId'); }))[0];
        pos = this.model.indexOf(seq);
        this.ctx.fillRect(this.coords.model_to_screen(sel.get('xStart'),'x'), this.coords.model_to_screen(pos, 'y'), 
                          this.coords.model_to_screen(sel.get('xEnd') - sel.get('xStart') + 1, 'x'), this.coords.boxes_size.y);
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

    const rect = this._calcSelection( mouse.abs(e) );
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
    let dragRel = [dragMove[0] - this.dragStart[0], dragMove[1] - this.dragStart[1]];

    // relative to target
    for (var i = 0; i <= 1; i++) {
      dragRel[i] = this.dragStartRel[i] + dragRel[i];
    }

    // 0:x, 1: y
    const rect = [[this.dragStartRel[0], dragRel[0]], [this.dragStartRel[1], dragRel[1]]];

    // swap the coordinates if needed
    for (let i = 0; i <= 1; i++) {
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

    const rect = this._calcSelection(dragEnd);

    // x
    for (var i = 0; i <= 1; i++) {
      rect[0][i] = this.coords.screen_to_model(rect[0][i], 'x');
    }

    // y
    for (var i = 0; i <= 1; i++) {
      rect[1][i] = this.coords.screen_to_model(rect[1][i], 'y');
    }

    // upper limit
    rect[0][1] = Math.min(this.model.getMaxLength() - 1, rect[0][1]);
    rect[1][1] = Math.min(this.model.length - 1, rect[1][1]);

    // select
    var selis = [];
    for (let j = rect[1][0]; j <= rect[1][1]; j++) {
      const args = {seqId: this.model.at(j).get('id'), xStart: rect[0][0], xEnd: rect[0][1]};
      selis.push(new possel(args));
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
    this.coords.updatecoords_transform(this);

    this.el.height = this.coords.container_size.y;
    this.el.width = this.coords.container_size.x;
    this.ctx = this.el.getContext("2d");
    this.el.style.overflow = "auto";
    return this.el.style.cursor = "crosshair";
  }
});
export default OverviewBox;
