BMath = require "../utils/bmath"
module.exports =
  class MenuBuilder

    constructor: (@name) ->
      @_nodes =  []

    addNode: (label, callback) ->
      @_nodes.push {label: label, callback: callback}

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

      menuUl = document.createElement "ul"
      menuUl.className = "dropdown-menu"

      # dropdown menu
      for node in nodes
        li = document.createElement "li"

        li.textContent = node.label
        li.addEventListener "click", node.callback

        menuUl.appendChild li

      menu.appendChild menuUl


      frag = document.createDocumentFragment()
      # diplay it
      displayedButton = document.createElement "a"
      displayedButton.textContent = name
      displayedButton.setAttribute "data-dropdown", "#" + menu.id
      displayedButton.className = "biojs_msa_menubar_alink"
      #data-dropdown="#dropdown-2" class="alink"

      frag.appendChild menu
      frag.appendChild displayedButton
      return  frag
