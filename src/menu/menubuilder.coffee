builder = require "menu-builder"

module.exports = MenuBuilder = builder.extend

    buildDOM: ->
      @.on "new:node", @buildNode
      @.on "new:button", @buildButton
      @.on "new:menu", @buildMenu
      return builder::buildDOM.call @

    buildNode: (li) ->
      if @g?
        li.style.lineHeight = @g.zoomer.get "menuItemLineHeight"

    buildButton: (btn) ->
      if @g?
        btn.style.fontSize = @g.zoomer.get "menuFontsize"
        btn.style.marginLeft = @g.zoomer.get "menuMarginLeft"
        btn.style.padding = @g.zoomer.get "menuPadding"

    buildMenu: (menu) ->
      if @g?
        menu.style.fontSize = @g.zoomer.get "menuItemFontsize"
