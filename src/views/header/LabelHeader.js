var LabelHeader;
var k = require("koala-js");
var view = require("backbone-viewj");
var dom = require("dom-helper");

module.exports = LabelHeader = view.extend({

  className: "biojs_msa_headers",

  initialize: function(data) {
    this.g = data.g;

    this.listenTo(this.g.vis, "change:metacell change:labels", this.render);
    return this.listenTo(this.g.zoomer, "change:labelWidth change:metaWidth", this.render);
  },

  render: function() {

    dom.removeAllChilds(this.el);

    var width = 0;
    width += this.g.zoomer.getLeftBlockWidth();
    this.el.style.width = width + "px";

    if (this.g.vis.get("labels")) {
      this.el.appendChild(this.labelDOM());
    }

    if (this.g.vis.get("metacell")) {
      this.el.appendChild(this.metaDOM());
    }

    this.el.style.display = "inline-block";
    this.el.style.fontSize = this.g.zoomer.get("markerFontsize");
    return this;
  },

  labelDOM: function() {
    var labelHeader = k.mk("div");
    labelHeader.style.width = this.g.zoomer.getLabelWidth();
    labelHeader.style.display = "inline-block";

    if (this.g.vis.get("labelCheckbox")) {
      labelHeader.appendChild(this.addEl(".", 10));
    }

    if (this.g.vis.get("labelId")) {
      labelHeader.appendChild(this.addEl("ID", this.g.zoomer.get("labelIdLength")));
    }

    if (this.g.vis.get("labelPartition")) {
      labelHeader.appendChild(this.addEl("part", 15));
    }

    if (this.g.vis.get("labelName")) {
      var name = this.addEl("Label");
      //name.style.marginLeft = "50px"
      labelHeader.appendChild(name);
    }

    return labelHeader;
  },

  addEl: function(content, width) {
    var id = document.createElement("span");
    id.textContent = content;
    if ((typeof width !== "undefined" && width !== null)) {
      id.style.width = width + "px";
    }
    id.style.display = "inline-block";
    return id;
  },

  metaDOM: function() {
    var metaHeader = k.mk("div");
    metaHeader.style.width = this.g.zoomer.getMetaWidth();
    metaHeader.style.display = "inline-block";

    if (this.g.vis.get("metaGaps")) {
      metaHeader.appendChild(this.addEl("Gaps", this.g.zoomer.get('metaGapWidth')));
    }
    if (this.g.vis.get("metaIdentity")) {
      metaHeader.appendChild(this.addEl("Ident", this.g.zoomer.get('metaIdentWidth')));
    }
    // if @.g.vis.get "metaLinks"
    //   metaHeader.appendChild @addEl("Links")

    return metaHeader;
  }
});
