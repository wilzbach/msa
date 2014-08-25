view = require("../../bone/view")
dom = require "../../utils/dom"

LabelView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g

    @manageEvents()

  manageEvents: ->
    events = {}
    events.click = "_onclick"
    if @g.config.get "registerMouseEvents"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events
    @listenTo @g.config, "change:registerMouseEvents", @manageEvents

  render: ->
    dom.removeAllChilds @el

    @el.style.width = "#{@g.zoomer.get "labelWidth"}px"
    @el.style.height = "#{@g.zoomer.get "rowHeight"}px"
    @el.style.fontSize = "#{@g.zoomer.get "labelFontsize"}px"
    @el.setAttribute "class", "biojs_msa_labels"

    if @.g.vis.get "labelId"
      id = document.createElement "span"
      id.textContent = @model.get "id"
      id.style.width = 30
      id.style.display = "inline-block"
      @el.appendChild id
    if @.g.vis.get "labelName"
      name = document.createElement "span"
      name.textContent = @model.get("name").substring 0, 20
      @el.appendChild name

    @el.style.overflow = scroll
    @

  _onclick: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:click", {seqId:seqId, evt:evt}

  _onmousein: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:mouseout", {seqId:seqId, evt:evt}

  _onmouseout: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:mouseout", {seqId:seqId, evt:evt}

module.exports = LabelView
