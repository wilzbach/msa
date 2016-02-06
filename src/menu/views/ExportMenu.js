var ExportMenu;
var MenuBuilder = require("../menubuilder");
var FastaExporter = require("biojs-io-fasta").writer;
var _ = require("underscore");
var Exporter = require("../../utils/export");

module.exports = ExportMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    this.msa = data.msa;
    return this.el.style.display = "inline-block";
  },

  render: function() {
    this.setName("Export");

    this.addNode("Share view (URL) ↪", () => {
      return Exporter.shareLink(this.msa, function(link) {
        return window.open(link, '_blank');
      });
    });

    this.addNode("View in Jalview", () => {
      var url = this.g.config.get('url');
      if (!(typeof url !== "undefined" && url !== null)) {
        return alert("Sequence weren't imported via an URL");
      } else {
        if (url.indexOf("localhost" || url === "dragimport")) {
          return Exporter.publishWeb(this.msa, (link) => {
            return Exporter.openInJalview(link, this.g.colorscheme.get("scheme"));
          });
        } else {
          return Exporter.openInJalview(url, this.g.colorscheme.get("scheme"));
        }
      }
    });

    this.addNode("Export alignment (FASTA)", () => {
      return Exporter.saveAsFile(this.msa, "all.fasta");
    });

    this.addNode("Export alignment (URL)", () => {
      return Exporter.publishWeb(this.msa, function(link) {
        return window.open(link, '_blank');
      });
    });

    this.addNode("Export selected sequences (FASTA)", () => {
      return Exporter.saveSelection(this.msa, "selection.fasta");
    });

    this.addNode("Export features (GFF)", () => {
      return Exporter.saveAnnots(this.msa, "features.gff3");
    });

    this.addNode("Export MSA image (PNG)", () => {
      return Exporter.saveAsImg(this.msa, "biojs-msa.png");
    });

    this.el.appendChild(this.buildDOM());
    return this;
  }
});
