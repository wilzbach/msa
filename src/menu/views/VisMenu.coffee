MenuBuilder = require "../menubuilder"
dom = require "dom-helper"

module.exports = VisMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"
    @listenTo @g.vis, "change", @render

  render: ->
    @removeAllNodes()
    @setName("Vis.elements")

    visElements = @getVisElements()
    for visEl in visElements
      @_addVisEl visEl

    # other
    @addNode "Reset", =>
      @g.vis.set "labels", true
      @g.vis.set "sequences", true
      @g.vis.set "metacell", true
      @g.vis.set "conserv", true
      @g.vis.set "labelId", true
      @g.vis.set "labelName", true
      @g.vis.set "labelCheckbox", false
      @g.vis.set "seqlogo", false
      @g.vis.set "gapHeader", false
      @g.vis.set "leftHeader", true
      @g.vis.set "metaGaps", true
      @g.vis.set "metaIdentity", true
      @g.vis.set "metaLinks", true

    # TODO: make more efficient
    dom.removeAllChilds @el
    @el.appendChild @buildDOM()
    @

  _addVisEl: (visEl) ->
    style = {}

    if @g.vis.get visEl.id
      pre = "Hide "
      style.color = "red"
    else
      pre = "Show "
      style.color = "green"

    @addNode (pre + visEl.name), =>
      @g.vis.set visEl.id, ! @g.vis.get visEl.id
    ,
      style: style

  getVisElements: ->
    vis = []
    vis.push name: "Position markers", id: "markers"
    vis.push name: "Id/Name", id: "labels"
    #vis.push name: "Sequences", id: "sequences"
    vis.push name: "Meta info (gaps/identity)", id: "metacell"
    vis.push name: "Overviewpanel", id: "overviewbox"
    vis.push name: "Sequence logo", id: "seqlogo"
    vis.push name: "Gap weights", id: "gapHeader"
    vis.push name: "Conservation weights", id: "conserv"
    #vis.push name: "Left header", id: "leftHeader"
    vis.push name: "Seq. name", id: "labelName"
    vis.push name: "Seq. id", id: "labelId"
    #vis.push name: "Label checkbox", id: "labelCheckbox"
    vis.push name: "Gaps %", id: "metaGaps"
    vis.push name: "Identity score", id: "metaIdentity"
    vis.push name: "Meta links", id: "metaLinks"
    return vis
