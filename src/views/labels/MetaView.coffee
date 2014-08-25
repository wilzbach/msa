view = require("../../bone/view")
MenuBuilder = require "../../menu/menubuilder"
_ = require 'underscore'
dom = require "../../utils/dom"

module.exports = MetaView = view.extend

  className: "biojs_msa_metaview"

  initialize: (data) ->
    @g = data.g

  events:
    click: "_onclick"
    mousein: "_onmousein"
    mouseout: "_onmouseout"

  render: ->
    dom.removeAllChilds @el

    @el.style.display = "inline-block"

    width = @g.zoomer.get "metaWidth"
    @el.style.width = width - 5
    @el.style.paddingRight = 5

    # adds gaps
    seq = @model.get('seq')
    gaps = _.reduce seq, ((memo, c) -> memo++ if c is '-';memo),0
    gaps = (gaps / seq.length).toFixed(1)

    # append gap count
    gapSpan = document.createElement 'span'
    gapSpan.textContent = gaps
    gapSpan.style.display = "inline-block"
    gapSpan.style.width = 35
    @el.appendChild gapSpan

    # identity
    ident = @model.get('identity')
    identSpan = document.createElement 'span'
    identSpan.textContent = ident.toFixed(2)
    identSpan.style.display = "inline-block"
    identSpan.style.width = 40
    @el.appendChild identSpan

    # TODO: this menu builder is just an example how one could customize this
    # view
    menu = new MenuBuilder("↗")
    menu.addNode "Uniprot",(e) =>
      window.open "http://beta.uniprot.org/uniprot/Q7T2N8"
    @el.appendChild menu.buildDOM()
    @el.width = 10

    @el.style.height = "#{@g.zoomer.get "rowHeight"}px"
    @el.style.cursor = "pointer"

  _onclick: (evt) ->
    @g.trigger "meta:click", {seqId: @model.get "id", evt:evt}

  _onmousein: (evt) ->
    @g.trigger "meta:mousein", {seqId: @model.get "id", evt:evt}

  _onmouseout: (evt) ->
    @g.trigger "meta:mouseout", {seqId: @model.get "id", evt:evt}
