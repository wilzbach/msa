var MenuView;
var boneView = require("backbone-childs");

// menu views
var ImportMenu = require("./views/ImportMenu");
var FilterMenu = require("./views/FilterMenu");
var SelectionMenu = require("./views/SelectionMenu");
var VisMenu = require("./views/VisMenu");
var ColorMenu = require("./views/ColorMenu");
var OrderingMenu = require("./views/OrderingMenu");
var ExtraMenu = require("./views/ExtraMenu");
var ExportMenu = require("./views/ExportMenu");
var HelpMenu = require("./views/HelpMenu");
var DebugMenu = require("./views/DebugMenu");
var MenuSettings = require("./settings");

// this very basic menu demonstrates calls to the MSA component
module.exports = MenuView = boneView.extend({

  initialize: function(data) {
    if(!data.msa){
      throw new Error("No msa instance provided. Please provide .msa");
    }
    this.msa = data.msa;

    // add menu config to the global object
    this.msa.g.menuconfig = new MenuSettings(data.menu);

    this.addView("10_import", new ImportMenu({model: this.msa.seqs, g:this.msa.g, msa: this.msa}));
    this.addView("15_ordering", new OrderingMenu({model: this.msa.seqs, g:this.msa.g}));
    this.addView("20_filter", new FilterMenu({model: this.msa.seqs, g:this.msa.g}));
    this.addView("30_selection", new SelectionMenu({model: this.msa.seqs, g:this.msa.g}));
    this.addView("40_vis", new VisMenu({model: this.msa.seqs, g:this.msa.g}));
    this.addView("50_color", new ColorMenu({model: this.msa.seqs, g:this.msa.g}));
    this.addView("70_extra", new ExtraMenu({model: this.msa.seqs, g:this.msa.g, msa: this.msa}));
    this.addView("80_export", new ExportMenu({model: this.msa.seqs, g:this.msa.g, msa:this.msa}));
    this.addView("90_help", new HelpMenu({g:this.msa.g}));
    if (this.msa.g.config.get("debug")) {
      return this.addView("95_debug", new DebugMenu({g:this.msa.g}));
    }
  },

  render: function() {
    this.renderSubviews();
    // other
    this.el.setAttribute("class", "smenubar");
    return this.el.appendChild(document.createElement("p"));
  }
});
