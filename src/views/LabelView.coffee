view = require("./view")

LabelView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g
    @el.setAttribute "class", "biojs_msa_labels"

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
    #@renderSubviews()
    @el.style.width = "#{@g.zoomer.get "labelOffset"}px"
    @el.style.height = "#{@g.zoomer.get "columnHeight"}px"
    @el.style.fontSize = "#{@g.zoomer.get "labelFontsize"}px"

    if @g.zoomer.get "textVisible"
      @el.textContent = @model.get "name"
    else
      @el.textContent = ""
    @el.textContent = @model.get("name").substring 0, 20

    @

  _onclick: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:click", {seqId:seqId, evt:evt}
    #@msa.selmanager.handleSel new selection.HorizontalSelection(@msa, id), evt

  _onmousein: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:mouseout", {seqId:seqId, evt:evt}
    #@msa.selmanager.handleSel new selection.HorizontalSelection(@msa, id), evt

  _onmouseout: (evt) ->
    seqId = @model.get "id"
    @g.trigger "row:mouseout", {seqId:seqId, evt:evt}
    #@msa.selmanager.handleSel new selection.HorizontalSelection(@msa, id), evt

module.exports = LabelView
