view = require("backbone-viewj")
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
    @listenTo @g.vis, "change:labelName change:labelId change:labelPartition change:labelCheckbox", @render
    @listenTo @g.zoomer, "change:labelIdLength change:labelNameLength
    change:labelPartLength change:labelCheckLength", @render
    @listenTo @g.zoomer, "change:labelFontSize change:labelLineHeight
    change:labelWidth change:rowHeight", @render

  render: ->
    dom.removeAllChilds @el

    @el.style.width = "#{@g.zoomer.getLabelWidth()}px"
    #@el.style.height = "#{@g.zoomer.get "rowHeight"}px"
    @el.setAttribute "class", "biojs_msa_labels"

    if @.g.vis.get "labelCheckbox"
      checkBox = document.createElement "input"
      checkBox.setAttribute "type", "checkbox"
      checkBox.value = @model.get('id')
      checkBox.name = "seq"
      checkBox.style.width= @g.zoomer.get("labelCheckLength") + "px"
      @el.appendChild checkBox

    if @.g.vis.get "labelId"
      id = document.createElement "span"
      val  = @model.get "id"
      unless isNaN val
        val++
      id.textContent = val
      id.style.width = @g.zoomer.get("labelIdLength") + "px"
      id.style.display = "inline-block"
      @el.appendChild id

    if @.g.vis.get "labelPartition"
      part = document.createElement "span"
      part.style.width= @g.zoomer.get("labelPartLength") + "px"
      part.textContent = @model.get("partition")
      part.style.display = "inline-block"
      @el.appendChild id
      @el.appendChild part

    if @.g.vis.get "labelName"
      name = document.createElement "span"
      name.textContent = @model.get("name")
      if @model.get("ref") and @g.config.get "hasRef"
        name.style.fontWeight = "bold"
      name.style.width= @g.zoomer.get("labelNameLength") + "px"
      @el.appendChild name

    @el.style.overflow = scroll
    @el.style.fontSize = "#{@g.zoomer.get('labelFontsize')}px"
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
