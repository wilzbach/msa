var ColorMenu;
var MenuBuilder = require("../menubuilder");
var _ = require("underscore");
var dom = require("dom-helper");

module.exports = ColorMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    this.el.style.display = "inline-block";
    return this.listenTo(this.g.colorscheme, "change", function() {
      return this.render();
    });
  },

  render: function() {
    var menuColor = this.setName("Color scheme");
    this.removeAllNodes();

    var colorschemes = this.getColorschemes();
    for (var i = 0, scheme; i < colorschemes.length; i++) {
      scheme = colorschemes[i];
      this.addScheme(menuColor, scheme);
    }

    // text = "Background"
    // if @g.colorscheme.get("colorBackground")
    //   text = "Hide " + text
    // else
    //   text = "Show " + text

    // @addNode text, =>
    //   @g.colorscheme.set "colorBackground", !@g.colorscheme.get("colorBackground")

    this.grey(menuColor);

    // TODO: make more efficient
    dom.removeAllChilds(this.el);
    this.el.appendChild(this.buildDOM());
    return this;
  },

  addScheme: function(menuColor,scheme) {
    var style = {};
    var current = this.g.colorscheme.get("scheme");
    if (current === scheme.id) {
      style.backgroundColor = "#77ED80";
    }

    return this.addNode(scheme.name, () => {
      this.g.colorscheme.set("scheme", scheme.id)
    }, {
        style: style
    });
  },

  getColorschemes: function() {
    var schemes  = [];
    schemes.push({name: "Taylor", id: "taylor"});
    schemes.push({name: "Buried", id: "buried"});
    schemes.push({name: "Cinema", id: "cinema"});
    schemes.push({name: "Clustal", id: "clustal"});
    schemes.push({name: "Clustal2", id: "clustal2"});
    schemes.push({name: "Helix", id: "helix"});
    schemes.push({name: "Hydrophobicity", id: "hydro"});
    schemes.push({name: "Lesk", id: "lesk"});
    schemes.push({name: "MAE", id: "mae"});
    schemes.push({name: "Nucleotide", id: "nucleotide"});
    schemes.push({name: "Purine", id: "purine"});
    schemes.push({name: "PID", id: "pid"});
    schemes.push({name: "Strand", id: "strand"});
    schemes.push({name: "Turn", id: "turn"});
    schemes.push({name: "Zappo", id: "zappo"});
    schemes.push({name: "No color", id: "foo"});
    return schemes;
  },

  grey: function(menuColor) {

    // greys all lowercase letters
    // @addNode "Shade", =>
    //   @g.colorscheme.set "showLowerCase", false
    //   @model.each (seq) ->
    //     residues = seq.get "seq"
    //     grey = []
    //     _.each residues, (el, index) ->
    //       if el is el.toLowerCase()
    //         grey.push index
    //     seq.set "grey", grey

    // @addNode "Shade by threshold", =>
    //   threshold = prompt "Enter threshold (in percent)", 20
    //   threshold = threshold / 100
    //   maxLen = @model.getMaxLength()
    //   # TODO: cache
    //   conserv = @g.stats.scale @g.stats.conservation()
    //   grey = []
    //   for i in [0.. maxLen - 1]
    //     if conserv[i] < threshold
    //       grey.push i
    //   @model.each (seq) ->
    //     seq.set "grey", grey

    // @addNode "Shade selection", =>
    //   maxLen = @model.getMaxLength()
    //   @model.each (seq) =>
    //     blocks = @g.selcol.getBlocksForRow(seq.get("id"),maxLen)
    //     seq.set "grey", blocks

    // @addNode "Reset shade", =>
    //   @g.colorscheme.set "showLowerCase", true
    //   @model.each (seq) ->
    //     seq.set "grey", []
  }
});