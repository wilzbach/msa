var HelpMenu;
var MenuBuilder = require("../menubuilder");

module.exports = HelpMenu = MenuBuilder.extend({

  initialize: function(data) {
    return this.g = data.g;
  },

  render: function() {
    this.setName("Help");
    this.addNode("About the project", function () {
      return window.open("https://github.com/wilzbach/msa");
    });
    this.addNode("Report issues", function () {
      return window.open("https://github.com/wilzbach/msa/issues");
    });
    this.addNode("User manual", function () {
      return window.open("https://github.com/wilzbach/msa/wiki");
    });
    this.el.style.display = "inline-block";
    this.el.appendChild(this.buildDOM());
    return this;
  }
});
