view = require("../../bone/view")
dom = require "dom-helper"

LabelView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g

    @manageEvents()

  manageEvents: ->
    events = {}
    if @g.config.get "registerMouseClicks"
      events.click = "_onclick"
    if @g.config.get "registerMouseHover"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events
    @listenTo @g.config, "change:registerMouseHover", @manageEvents
    @listenTo @g.config, "change:registerMouseClick", @manageEvents
    @listenTo @g.vis, "change:labelName", @render
    @listenTo @g.vis, "change:labelId", @render
    @listenTo @g.vis, "change:labelPartition", @render
    @listenTo @g.vis, "change:labelCheckbox", @render

  render: ->
    dom.removeAllChilds @el

    @el.style.width = "#{@g.zoomer.get "labelWidth"}px"
    @el.style.height = "#{@g.zoomer.get "rowHeight"}px"
    @el.setAttribute "class", "biojs_msa_labels"

    if @.g.vis.get "labelCheckbox"
      checkBox = document.createElement "input"
      checkBox.setAttribute "type", "checkbox"
      checkBox.value = @model.get('id')
      checkBox.name = "seq"
      @el.appendChild checkBox

    if @.g.vis.get "labelId"
      id = document.createElement "span"
      id.textContent = @model.get "id"
      id.style.width = @g.zoomer.get "labelIdLength"
      id.style.display = "inline-block"
      @el.appendChild id

    if @.g.vis.get "labelPartition"
      part = document.createElement "span"
      part.style.width = 15
      part.textContent = @model.get("partition")
      part.style.display = "inline-block"
      @el.appendChild id
      @el.appendChild part

    if @.g.vis.get "labelName"
      name = document.createElement "span"
      name.textContent = @model.get("name")
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
