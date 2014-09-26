BMath = require "../utils/bmath"
jbone = require "jbone"
view = require("backbone-viewj")

#jbone.fn.addClass = (className) ->
#  for i in [0.. @.length - 1] by 1
#    @[i].classList.add className
#  @

module.exports = MenuBuilder = view.extend

    setName: (@name) ->
      @_nodes =  []

    addNode: (label, callback, data) ->
      style = data.style if data?
      @_nodes = [] unless @_nodes?
      @_nodes.push {label: label, callback: callback, style: style}

    buildDOM: ->
      @_buildM
        nodes: @_nodes
        name: @name

    _buildM: (data) ->
      nodes = data.nodes
      name = data.name

      menu = document.createElement "div"
      menu.className = "dropdown dropdown-tip"
      menu.id = "adrop-" + BMath.uniqueId()
      menu.style.display = "none"

      menuUl = document.createElement "ul"
      menuUl.className = "dropdown-menu"

      # dropdown menu
      for node in nodes
        li = document.createElement "li"

        li.textContent = node.label
        for key,style of node.style
          li.style[key] = style
        li.addEventListener "click", node.callback
        if @g?
          li.style.lineHeight = @g.zoomer.get "menuItemLineHeight"

        menuUl.appendChild li

      menu.appendChild menuUl

      frag = document.createDocumentFragment()
      # diplay it
      displayedButton = document.createElement "a"
      displayedButton.textContent = name
      displayedButton.className = "biojs_msa_menubar_alink"

      # tiny style
      if @g?
        menuUl.style.fontSize = @g.zoomer.get "menuItemFontsize"
        displayedButton.style.fontSize = @g.zoomer.get "menuFontsize"
        displayedButton.style.marginLeft = @g.zoomer.get "menuMarginLeft"
        displayedButton.style.padding = @g.zoomer.get "menuPadding"

      jbone(displayedButton).on "click", (e) =>
        @_showMenu e,menu,displayedButton

        # wait until event is bubbled to the top
        window.setTimeout ->
          jbone(document.body).one "click", (e) ->
            console.log "next click"
            menu.style.display = "none"
        , 5


      frag.appendChild menu
      frag.appendChild displayedButton
      return  frag

    _showMenu: (e, menu, target) ->
      #jbone(menu).addClass "dropdown-open"
      menu.style.display = "block"
      menu.style.position = "absolute"

      rect = target.getBoundingClientRect()
      menu.style.left = rect.left + "px"
      menu.style.top = (rect.top + target.offsetHeight) + "px"
