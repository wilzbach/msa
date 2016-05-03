var SelectionMenu;
var MenuBuilder = require("../menubuilder");

module.exports = SelectionMenu = MenuBuilder.extend({

  initialize(data) {
    this.g = data.g;
    return this.el.style.display = "inline-block";
  },

  render() {
    this.setName("Selection");
    this.addNode("Find Motif (supports RegEx)", function () {
      var search = prompt("your search", "D");
      return this.g.user.set("searchText", search);
    });

    this.addNode("Invert columns", function () {
      return this.g.selcol.invertCol(((function() {
        var result = [];
        var end = this.model.getMaxLength();
        var i = 0;
        if (0 <= end) {
          while (i <= end) {
            result.push(i++);
          }
        } else {
          while (i >= end) {
            result.push(i--);
          }
        }
        return result;
      })()));
    });
    this.addNode("Invert rows", function () {
      return this.g.selcol.invertRow(this.model.pluck("id"));
    });
    this.addNode("Reset", function () {
      return this.g.selcol.reset();
    });
    this.el.appendChild(this.buildDOM());
    return this;
  }
});
