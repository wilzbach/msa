var boneView = require("backbone-childs");
var _ = require('underscore');
var k = require('koala-js');
var dom = require('dom-helper');
var sel = require("../g/selection/Selection");

// this is a very simplistic approach to show search result
// TODO: needs proper styling
module.exports = boneView.extend({

  initialize: function(data) {
    this.g = data.g;

    this.listenTo(this.g.user, "change:searchText", function(model, prop) {
      this.search(prop);
      return this.render();
    });
    this.sel = [];
    return this.selPos = 0;
  },

  events:
    {"scroll": "_sendScrollEvent"},

  render: function() {
    this.renderSubviews();

    this.el.className = "biojs_msa_searchresult";
    var searchText = this.g.user.get("searchText");
    if ((typeof searchText !== "undefined" && searchText !== null) && searchText.length > 0) {
      if (this.sel.length === 0) {
        this.el.textContent = "no selection found";
      } else {
        this.resultBox = k.mk("div");
        this.resultBox.className = "biojs_msa_searchresult_ovbox";
        this.updateResult();
        this.el.appendChild(this.resultBox);
        this.el.appendChild(this.buildBtns());
      }
    }
    return this;
  },

  updateResult: function() {
      var text = "search pattern: " + this.g.user.get("searchText");
      text += ", selection: " + (this.selPos + 1);
      var seli = this.sel[this.selPos];
      text += " (";
      text += seli.get("xStart") + " - " + seli.get("xEnd");
      text += ", id: " + seli.get("seqId");
      text += ")";
      return this.resultBox.textContent = text;
  },

  buildBtns: function() {
    var prevBtn = k.mk("button");
    prevBtn.textContent = "Prev";
    prevBtn.addEventListener("click", () => {
      return this.moveSel(-1);
    });

    var nextBtn = k.mk("button");
    nextBtn.textContent = "Next";
    nextBtn.addEventListener("click", () => {
      return this.moveSel(1);
    });

    var allBtn = k.mk("button");
    allBtn.textContent = "All";
    allBtn.addEventListener("click", () => {
      return this.g.selcol.reset(this.sel);
    });

    var searchrow = k.mk("div");
    searchrow.appendChild(prevBtn);
    searchrow.appendChild(nextBtn);
    searchrow.appendChild(allBtn);
    searchrow.className = "biojs_msa_searchresult_row";
    return searchrow;
  },

  moveSel: function(relDist) {
    var selNew = this.selPos + relDist;
    if (selNew < 0 || selNew >= this.sel.length) {
      return -1;
    } else {
      this.focus(selNew);
      this.selPos = selNew;
      return this.updateResult();
    }
  },

  focus: function(selPos) {
    var seli = this.sel[selPos];
    var leftIndex = seli.get("xStart");
    this.g.zoomer.setLeftOffset(leftIndex);
    return this.g.selcol.reset([seli]);
  },

  search: function(searchText) {
    // marks all hits
    var origIndex;
    var search = new RegExp(searchText, "gi");
    var newSeli = [];
    var leftestIndex = origIndex = 100042;

    this.model.each(function(seq) {
      var strSeq = seq.get("seq");
      return (() => {
        var match;
        var result = [];
        while (match = search.exec(strSeq)) {
          var index = match.index;
          var args = {xStart: index, xEnd: index + match[0].length - 1, seqId:
            seq.get("id")};
          newSeli.push(new sel.possel(args));
          result.push(leftestIndex = Math.min(index, leftestIndex));
        }
        return result;
      })();
    });

    this.g.selcol.reset(newSeli);

    // safety check + update offset
    if (leftestIndex === origIndex) { leftestIndex = 0; }
    this.g.zoomer.setLeftOffset(leftestIndex);

    return this.sel = newSeli;
  }
});
