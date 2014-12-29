view = require("backbone-viewj")
MenuBuilder = require "../../menu/menubuilder"
_ = require 'underscore'
dom = require "dom-helper"
st = require "biojs-utils-seqtools"

module.exports = MetaView = view.extend

  className: "biojs_msa_metaview"

  initialize: (data) ->
    @g = data.g
    @listenTo @g.vis, "change:metacell", @render
    @listenTo @g.zoomer, "change:metaWidth", @render

  events:
    click: "_onclick"
    mousein: "_onmousein"
    mouseout: "_onmouseout"

  render: ->
    dom.removeAllChilds @el

    @el.style.display = "inline-block"

    width = @g.zoomer.getMetaWidth()
    @el.style.width = width - 10
    @el.style.paddingRight = 5
    @el.style.paddingLeft = 5
    # TODO: why do we need to decrease the font size?
    # otherwise we see a scrollbar
    @el.style.fontSize = "#{@g.zoomer.get('labelFontsize') - 2}px"

    if @.g.vis.get "metaGaps"
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


    if @.g.vis.get "metaIdentity"
      # identity
      # TODO: there must be a better way to pass the id
      ident = @g.stats.identity()[@model.id]
      identSpan = document.createElement 'span'

      if @model.get("ref") and @g.config.get "hasRef"
        identSpan.textContent = "ref."
      else if ident?
        identSpan.textContent = ident.toFixed(2)

      identSpan.style.display = "inline-block"
      identSpan.style.width = 40
      @el.appendChild identSpan

    if @.g.vis.get "metaLinks"
      # TODO: this menu builder is just an example how one could customize this
      # view
      if @model.attributes.ids
        menu = new MenuBuilder({name: "↗"})
        links = st.buildLinks @model.attributes.ids
        _.each links, (val, key) ->
          menu.addNode key,(e) ->
            window.open val

        linkEl = menu.buildDOM()
        linkEl.style.cursor = "pointer"
        @el.appendChild linkEl


    #@el.style.height = "#{@g.zoomer.get "rowHeight"}px"

  _onclick: (evt) ->
    @g.trigger "meta:click", {seqId: @model.get "id", evt:evt}

  _onmousein: (evt) ->
    @g.trigger "meta:mousein", {seqId: @model.get "id", evt:evt}

  _onmouseout: (evt) ->
    @g.trigger "meta:mouseout", {seqId: @model.get "id", evt:evt}
