const boneView = require("backbone-childs");
import {debounce} from "lodash";

import AlignmentBody from "./AlignmentBody";
import HeaderBlock from "./header/HeaderBlock";
import OverviewBox from "./OverviewBox";
import Search from "./Search";
import ScaleSlider from "./ScaleSlider";

// a neat collection view
const View  = boneView.extend({

  initialize: function(data) {
    this.g = data.g;

    this.draw();
    //@listenTo @model,"reset", ->
    // we need to wait until stats gives us the ok
    this.listenTo(this.g.stats,"reset", function() {
      return this.rerender();
    });

    // debounce a bulk operation
    this.listenTo(this.model,"change:hidden", debounce(this.rerender, 10));

    this.listenTo(this.model,"sort", this.rerender);
    this.listenTo(this.model,"add", function() {
      return console.log("seq add");
    });

    this.listenTo(this.g.vis,"change:sequences", this.rerender);
    this.listenTo(this.g.vis,"change:overviewbox", this.rerender);
    this.listenTo(this.g.visorder,"change", this.rerender);
    this.listenTo(this.g.zoomer, "change:columnWidth", this.rerender);
    this.listenTo(this.g.vis,"change:scaleslider", this.rerender);

    return this;
  },

  draw: function() {
    this.removeViews();

    if (this.g.vis.get("overviewbox")) {
      var overviewbox = new OverviewBox({model: this.model, g: this.g});
      overviewbox.ordering = this.g.visorder.get('overviewBox');
      this.addView("overviewBox", overviewbox);
    }

    if (true) {
      var headerblock = new HeaderBlock({model: this.model, g: this.g});
      headerblock.ordering = this.g.visorder.get('headerBox');
      this.addView("headerBox", headerblock);
    }

    if (true) {
      var searchblock = new Search({model: this.model, g: this.g});
      searchblock.ordering = this.g.visorder.get('searchBox');
      this.addView("searchbox", searchblock);
    }

    var body = new AlignmentBody({model: this.model, g: this.g});
    body.ordering = this.g.visorder.get('alignmentBody');
    this.addView("body",body);

    if (this.g.vis.get("scaleslider")) {
      var scaleslider = new ScaleSlider({model: this.g.scale, g: this.g});
      scaleslider.ordering = this.g.visorder.get('scaleSlider');
      this.addView("scaleSlider", scaleslider);
    }

    return this;
  },

  render: function(e) {
    this.renderSubviews();
    this.el.className = "biojs_msa_stage";
    return this;
  },

  rerender: function() {
    if (!this.g.config.get("manualRendering")) {
      this.draw();
      return this.render();
    }
  }
});
export default View;
