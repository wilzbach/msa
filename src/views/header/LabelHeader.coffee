k = require "koala-js"
view = require("backbone-viewj")
dom = require("dom-helper")

module.exports = LabelHeader = view.extend

  className: "biojs_msa_headers"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.vis, "change:metacell change:labels", @render
    @listenTo @g.zoomer, "change:labelWidth change:metaWidth", @render

  render: ->

    dom.removeAllChilds @el

    width = 0
    width += @g.zoomer.getLeftBlockWidth()
    @el.style.width = width + "px"

    if @g.vis.get "labels"
      @el.appendChild @labelDOM()

    if @g.vis.get "metacell"
      @el.appendChild @metaDOM()

    @el.style.display = "inline-block"
    @el.style.fontSize = @g.zoomer.get "markerFontsize"
    @

  labelDOM: ->
    labelHeader = k.mk "div"
    labelHeader.style.width = @g.zoomer.getLabelWidth()
    labelHeader.style.display = "inline-block"

    if @.g.vis.get "labelCheckbox"
      labelHeader.appendChild @addEl(".", 10)

    if @.g.vis.get "labelId"
      labelHeader.appendChild @addEl("ID", @g.zoomer.get "labelIdLength")

    if @.g.vis.get "labelPartition"
      labelHeader.appendChild @addEl("part", 15)

    if @.g.vis.get "labelName"
      name = @addEl("Label")
      #name.style.marginLeft = "50px"
      labelHeader.appendChild name

    labelHeader

  addEl: (content, width) ->
    id = document.createElement "span"
    id.textContent = content
    if width?
      id.style.width = width + "px"
    id.style.display = "inline-block"
    id

  metaDOM: ->
    metaHeader = k.mk "div"
    metaHeader.style.width = @g.zoomer.getMetaWidth()
    metaHeader.style.display = "inline-block"

    if @.g.vis.get "metaGaps"
      metaHeader.appendChild @addEl("Gaps", @g.zoomer.get('metaGapWidth'))
    if @.g.vis.get "metaIdentity"
      metaHeader.appendChild @addEl("Ident", @g.zoomer.get('metaIdentWidth'))
    # if @.g.vis.get "metaLinks"
    #   metaHeader.appendChild @addEl("Links")

    metaHeader
