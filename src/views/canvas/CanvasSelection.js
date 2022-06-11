import {find, extend} from "lodash";

const CanvasSelection = (function(g,ctx) {
  this.g = g;
  this.ctx = ctx;
  return this;
}
);

extend(CanvasSelection.prototype, {

  // TODO: should I be moved to the selection manager?
  // returns an array with the currently selected residues
  // e.g. [0,3] = pos 0 and 3 are selected
  _getSelection: function(model) {
    const maxLen = model.get("seq").length;
    const selection = [];
    const sels = this.g.selcol.getSelForRow(model.get("id"));
    const rows = find(sels, function(el) { return el.get("type") === "row"; });
    if ((typeof rows !== "undefined" && rows !== null)) {
      // full match
      const end = maxLen - 1;
      for (let n = 0; n <= end; n++) {
        selection.push(n);
      }
    } else if (sels.length > 0) {
      for (let i = 0, sel; i < sels.length; i++) {
        sel = sels[i];
        const start = sel.get("xStart");
        const end = sel.get("xEnd");
        for (let n = start; n <= end; n++) {
          selection.push(n);
        }
      }
    }

    return selection;
  },

  // loops over all selection and calls the render method
  _appendSelection: function(data) {
    const seq = data.model.get("seq");
    const selection = this._getSelection(data.model);
    // get the status of the upper and lower row
    const getNextPrev= this._getPrevNextSelection(data.model);
    const mPrevSel = getNextPrev[0];
    const mNextSel = getNextPrev[1];

    const boxWidth = this.g.zoomer.get("columnWidth");
    const boxHeight = this.g.zoomer.get("rowHeight");

    // avoid unnecessary loops
    if (selection.length === 0) { return; }

    let hiddenOffset = 0;
    return (() => {
      const result = [];
      const end = seq.length - 1;
      for (let n = 0; n <= end; n++) {
        result.push((() => {
          if (data.hidden.indexOf(n) >= 0) {
            return hiddenOffset++;
          } else {
            const k = n - hiddenOffset;
            // only if its a new selection
            if (selection.indexOf(n) >= 0 && (k === 0 || selection.indexOf(n - 1) < 0 )) {
              return this._renderSelection({n:n,
                                           k:k,
                                           selection: selection,
                                           mPrevSel: mPrevSel,
                                           mNextSel:mNextSel,
                                           xZero: data.xZero,
                                           yZero: data.yZero,
                                           model: data.model});
            }
          }
        })());
      }
      return result;
    })();
  },

  // draws a single user selection
  _renderSelection: function(data) {

    let xZero = data.xZero;
    const yZero = data.yZero;
    const n = data.n;
    const k = data.k;
    const selection = data.selection;
    // and checks the prev and next row for selection  -> no borders in a selection
    const mPrevSel= data.mPrevSel;
    const mNextSel = data.mNextSel;

    // get the length of this selection
    let selectionLength = 0;
    const end = data.model.get("seq").length - 1;
    for (let i = n; i <= end; i++) {
      if (selection.indexOf(i) >= 0) {
        selectionLength++;
      } else {
        break;
      }
    }

    // TODO: ugly!
    const boxWidth = this.g.zoomer.get("columnWidth");
    const boxHeight = this.g.zoomer.get("rowHeight");
    const totalWidth = (boxWidth * selectionLength) + 1;

    const hidden = this.g.columns.get('hidden');

    this.ctx.beginPath();
    const beforeWidth = this.ctx.lineWidth;
    this.ctx.lineWidth = 3;
    const beforeStyle = this.ctx.strokeStyle;
    this.ctx.strokeStyle = "#FF0000";

    xZero += k * boxWidth;

    // split up the selection into single cells
    let xPart = 0;
    const end1 = selectionLength - 1;
    for (let i = 0; i <= end1; i++) {
      let xPos = n + i;
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

    const modelPrev = model.collection.prev(model);
    const modelNext = model.collection.next(model);
    let mPrevSel, mNextSel;
    if ((typeof modelPrev !== "undefined" && modelPrev !== null)) { mPrevSel = this._getSelection(modelPrev); }
    if ((typeof modelNext !== "undefined" && modelNext !== null)) { mNextSel = this._getSelection(modelNext); }
    return [mPrevSel,mNextSel];
  }
});
export default CanvasSelection;
