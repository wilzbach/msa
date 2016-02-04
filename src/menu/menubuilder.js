var MenuBuilder;
var builder = require("menu-builder");

module.exports = MenuBuilder = builder.extend({

    buildDOM: function() {
      this.on("new:node", this.buildNode);
      this.on("new:button", this.buildButton);
      this.on("new:menu", this.buildMenu);
      return builder.prototype.buildDOM.call(this);
    },

    buildNode: function(li) {
      if ((this.g != null)) {
        return li.style.lineHeight = this.g.menuconfig.get("menuItemLineHeight");
      }
    },

    buildButton: function(btn) {
      if ((this.g != null)) {
        btn.style.fontSize = this.g.menuconfig.get("menuFontsize");
        btn.style.marginLeft = this.g.menuconfig.get("menuMarginLeft");
        return btn.style.padding = this.g.menuconfig.get("menuPadding");
      }
    },

    buildMenu: function(menu) {
      if ((this.g != null)) {
        return menu.style.fontSize = this.g.menuconfig.get("menuItemFontsize");
      }
    }
});
