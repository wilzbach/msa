var SelectionClass;
var _ = require("underscore");

module.exports = SelectionClass = (function(g,ctx) {
  this.g = g;
  this.ctx = ctx;
  return this;
}
);

_.extend(SelectionClass.prototype, {

  // TODO: should I be moved to the selection manager?
  // returns an array with the currently selected residues
  // e.g. [0,3] = pos 0 and 3 are selected
  _getSelection: function(model) {
    var maxLen = model.get("seq").length;
    var selection = [];
    var sels = this.g.selcol.getSelForRow(model.get("id"));
    var rows = _.find(sels, function(el) { return el.get("type") === "row"; });
    if ((typeof rows !== "undefined" && rows !== null)) {
      // full match
      var end = maxLen - 1;
      for (var n = 0; n <= end; n++) {
        selection.push(n);
      }
    } else if (sels.length > 0) {
      for (var i = 0, sel; i < sels.length; i++) {
        sel = sels[i];
        var start = sel.get("xStart");
        var end = sel.get("xEnd");
        for (var n = start; n <= end; n++) {
          selection.push(n);
        }
      }
    }

    return selection;
  },

  // loops over all selection and calls the render method
  _appendSelection: function(data) {
    var seq = data.model.get("seq");
    var selection = this._getSelection(data.model);
    // get the status of the upper and lower row
    var [mPrevSel,mNextSel] = this._getPrevNextSelection(data.model);

    var boxWidth = this.g.zoomer.get("columnWidth");
    var boxHeight = this.g.zoomer.get("rowHeight");

    // avoid unnecessary loops
    if (selection.length === 0) { return; }

    var hiddenOffset = 0;
    return (() => {
      var result = [];
      var end = seq.length - 1;
      for (var n = 0; 0 < end ? n <= end : n >= end; 0 < end ? n++ : n--) {
        result.push((() => {
          if (data.hidden.indexOf(n) >= 0) {
            return hiddenOffset++;
          } else {
            var k = n - hiddenOffset;
            // only if its a new selection
            if (selection.indexOf(n) >= 0 && (k === 0 || selection.indexOf(n - 1) < 0 )) {
              return this._renderSelection({n:n,k:k,selection: selection,mPrevSel: mPrevSel,mNextSel:mNextSel, xZero: data.xZero, yZero: data.yZero, model: data.model});
            }
          }
        })());
      }
      return result;
    })();
  },

  // draws a single user selection
  _renderSelection: function(data) {

    var xZero = data.xZero;
    var yZero = data.yZero;
    var n = data.n;
    var k = data.k;
    var selection = data.selection;
    // and checks the prev and next row for selection  -> no borders in a selection
    var mPrevSel= data.mPrevSel;
    var mNextSel = data.mNextSel;

    // get the length of this selection
    var selectionLength = 0;
    var end = data.model.get("seq").length - 1;
    for (var i = n; n < end ? i <= end : i >= end; n < end ? i++ : i--) {
      if (selection.indexOf(i) >= 0) {
        selectionLength++;
      } else {
        break;
      }
    }

    // TODO: ugly!
    var boxWidth = this.g.zoomer.get("columnWidth");
    var boxHeight = this.g.zoomer.get("rowHeight");
    var totalWidth = (boxWidth * selectionLength) + 1;

    var hidden = this.g.columns.get('hidden');

    this.ctx.beginPath();
    var beforeWidth = this.ctx.lineWidth;
    this.ctx.lineWidth = 3;
    var beforeStyle = this.ctx.strokeStyle;
    this.ctx.strokeStyle = "#FF0000";

    xZero += k * boxWidth;

    // split up the selection into single cells
    var xPart = 0;
    var end1 = selectionLength - 1;
    for (var i = 0; 0 < end1 ? i <= end1 : i >= end1; 0 < end1 ? i++ : i--) {
      var xPos = n + i;
      if (hidden.indexOf(xPos) >= 0) {
        continue;
      }
      // upper line
      if (!((typeof mPrevSel !== "undefined" && mPrevSel !== null) && mPrevSel.indexOf(xPos) >= 0)) {
        this.ctx.moveTo(xZero + xPart, yZero);
        this.ctx.lineTo(xPart + boxWidth + xZero, yZero);
      }
      // lower line
      if (!((typeof mNextSel !== "undefined" && mNextSel !== null) && mNextSel.indexOf(xPos) >= 0)) {
        this.ctx.moveTo(xPart + xZero, boxHeight + yZero);
        this.ctx.lineTo(xPart + boxWidth + xZero, boxHeight + yZero);
      }

      xPart += boxWidth;
    }

    // left
    this.ctx.moveTo(xZero,yZero);
    this.ctx.lineTo(xZero, boxHeight + yZero);

    // right
    this.ctx.moveTo(xZero + totalWidth,yZero);
    this.ctx.lineTo(xZero + totalWidth, boxHeight + yZero);

    this.ctx.stroke();
    this.ctx.strokeStyle = beforeStyle;
    return this.ctx.lineWidth = beforeWidth;
  },

  // looks at the selection of the prev and next el
  // TODO: this is very naive, as there might be gaps above or below
  _getPrevNextSelection: function(model) {

    var modelPrev = model.collection.prev(model);
    var modelNext = model.collection.next(model);
    if ((typeof modelPrev !== "undefined" && modelPrev !== null)) { var mPrevSel = this._getSelection(modelPrev); }
    if ((typeof modelNext !== "undefined" && modelNext !== null)) { var mNextSel = this._getSelection(modelNext); }
    return [mPrevSel,mNextSel];
  }
});
