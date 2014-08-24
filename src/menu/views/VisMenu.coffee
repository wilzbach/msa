view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
dom = require "../../utils/dom"

module.exports = ImportMenu = view.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"
    @listenTo @g.vis, "change", @render

  render: ->
    menuFile = new MenuBuilder("Vis. elements")

    visElements = @getVisElements()
    for visEl in visElements
      @_addVisEl menuFile,visEl

    # other
    menuFile.addNode "Reset", =>
      @g.vis.set "labels", true
      @g.vis.set "sequences", true
      @g.vis.set "metacell", true
      @g.vis.set "conserv", true

    menuFile.addNode "Toggle mouseover events", =>
      @g.config.set "registerMouseEvents", !@g.config.get "registerMouseEvents"

    # TODO: make more efficient
    dom.removeAllChilds @el
    @el.appendChild menuFile.buildDOM()
    @

  _addVisEl: (menuFile,visEl) ->
    style = {}

    if @g.vis.get visEl.id
      pre = "Hide "
      style.color = "red"
    else
      pre = "Show "
      style.color = "green"

    menuFile.addNode (pre + visEl.name), =>
      @g.vis.set visEl.id, ! @g.vis.get visEl.id
    ,
      style: style

  getVisElements: ->
    vis = []
    vis.push name: "Markers", id: "markers"
    vis.push name: "Labels", id: "labels"
    vis.push name: "Sequences", id: "sequences"
    vis.push name: "Meta info", id: "metacell"
    vis.push name: "conserv", id: "conserv"
    return vis
