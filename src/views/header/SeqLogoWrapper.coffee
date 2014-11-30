SeqLogoView = require "biojs-vis-seqlogo/light"
view = require("backbone-viewj")
colorSelector = require("biojs-util-colorschemes").selector

# this is a bridge between the MSA and the seqlogo viewer
module.exports = view.extend

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:alignmentWidth", @render
    @listenTo @g.colorscheme, "change", ->
      console.log "color changed"
      colors = colorSelector.getColor(@g.colorscheme.get("scheme"))
      @seqlogo.changeColors colors
      @render()

    @listenTo @g.zoomer,"change:columnWidth", ->
        @seqlogo.column_width = @g.zoomer.get('columnWidth')
      @render

    #@listenTo @g.zoomer,"change:columnWidth change:rowHeight", ->

    @draw()


  draw: ->
    arr = @g.stats.conservResidue()
    arr = _.map arr, (el) ->
      _.pick el, (e,k) ->
        k isnt "-"
    data =
      alphabet: "aa"
      heightArr: arr

    colors = colorSelector.getColor(@g.colorscheme.get("scheme"))
    @seqlogo = new SeqLogoView {model: @model, g: @g, data: data, yaxis:false
        ,scroller: false,xaxis: false, height: 100, column_width: @g.zoomer.get('columnWidth')
        ,positionMarker: false, zoom: 1, el: @el,colors: colors}

  render: ->
    @seqlogo.render()
