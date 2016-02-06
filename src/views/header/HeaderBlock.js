var boneView = require("backbone-childs");
var LabelHeader = require("./LabelHeader");
var RightLabelHeader = require("./RightHeaderBlock");

module.exports = boneView.extend({

  initialize: function(data) {
    this.g = data.g;
    this.draw();
    return this.listenTo(this.g.vis,"change:labels change:metacell change:leftHeader", () => {
      this.draw();
      return this.render();
    });
  },

  draw: function() {
    this.removeViews();

    if (this.g.vis.get("leftHeader") && (this.g.vis.get("labels") || this.g.vis.get("metacell"))) {
      var lHeader = new LabelHeader({model: this.model, g: this.g});
      lHeader.ordering = -50;
      this.addView("lHeader", lHeader);
    }

    var rHeader = new RightLabelHeader({model: this.model, g: this.g});
    rHeader.ordering = 0;
    return this.addView("rHeader", rHeader);
  },

  render: function() {
    this.renderSubviews();

    return this.el.className = "biojs_msa_header";
  }
});
