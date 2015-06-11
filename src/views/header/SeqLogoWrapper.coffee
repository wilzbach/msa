SeqLogoView = require "biojs-vis-seqlogo/light"
view = require("backbone-viewj")
dom = require("dom-helper")

# this is a bridge between the MSA and the seqlogo viewer
module.exports = view.extend

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:alignmentWidth", @render
    @listenTo @g.colorscheme, "change", ->
      colors = @g.colorscheme.getSelectedScheme()
      @seqlogo.changeColors colors
      @render()

    @listenTo @g.zoomer,"change:columnWidth", ->
      @seqlogo.column_width = @g.zoomer.get('columnWidth')
      @render()

    #@listenTo @g.zoomer,"change:columnWidth change:rowHeight", ->

    @listenTo @g.stats, "reset", ->
      @draw()
      @render()

    @draw()


  draw: ->
    dom.removeAllChilds @el

    console.log "redraw seqlogo"
    arr = @g.stats.conservResidue {scaled: true}
    arr = _.map arr, (el) ->
      _.pick el, (e,k) ->
        k isnt "-"
    data =
      alphabet: "aa"
      heightArr: arr

    colors = @g.colorscheme.getSelectedScheme()
    # TODO: seqlogo might have problems with true dynamic schemes
    @seqlogo = new SeqLogoView {model: @model, g: @g, data: data, yaxis:false
        ,scroller: false,xaxis: false, height: 100, column_width: @g.zoomer.get('columnWidth')
        ,positionMarker: false, zoom: 1, el: @el,colors: colors}

  render: ->
    @seqlogo.render()
