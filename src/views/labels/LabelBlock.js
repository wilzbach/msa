var LabelRowView = require("./LabelRowView");
var boneView = require("backbone-childs");

module.exports = boneView.extend({

  initialize: function(data) {
    this.g = data.g;
    this.draw();
    this.listenTo(this.g.zoomer, "change:_alignmentScrollTop", this._adjustScrollingTop);
    this.g.vis.once('change:loaded', this._adjustScrollingTop , this);

    this.listenTo(this.g.zoomer,"change:alignmentHeight", this._setHeight);
    this.listenTo(this.model,"change:reference", this.draw);

    return this.listenTo(this.model,"reset add remove", () => {
      this.draw();
      return this.render();
    });
  },

  draw: function() {
    this.removeViews();
    console.log("redraw columns" , this.model.length);
    for (var i = 0; i < this.model.length; i++) {
        if (this.model.at(i).get('hidden')) { continue; }
        var view = new LabelRowView({model: this.model.at(i), g: this.g});
        view.ordering = i;
        this.addView("row_" + i, view)
    }
  },

  events:
    {"scroll": "_sendScrollEvent"},

  // broadcast the scrolling event (by the scrollbar)
  _sendScrollEvent: function() {
    return this.g.zoomer.set("_alignmentScrollTop", this.el.scrollTop, {origin: "label"});
  },

  // sets the scrolling property (from another event e.g. dragging)
  _adjustScrollingTop() {
    return this.el.scrollTop =  this.g.zoomer.get("_alignmentScrollTop");
  },

  render: function() {
    this.renderSubviews();
    this.el.className = "biojs_msa_labelblock";
    this.el.style.display = "inline-block";
    this.el.style.verticalAlign = "top";
    this.el.style.overflowY = "auto";
    this.el.style.overflowX = "hidden";
    this.el.style.fontSize = `${this.g.zoomer.get('labelFontsize')}px`;
    this.el.style.lineHeight = `${this.g.zoomer.get("labelLineHeight")}`;
    this._setHeight();
    return this;
  },


  _setHeight: function() {
    return this.el.style.height = this.g.zoomer.get("alignmentHeight") + "px";
  }
});
