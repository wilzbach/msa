boneView = require("backbone-childs")
_ = require 'underscore'
k = require 'koala-js'
dom = require 'dom-helper'
sel = require "../g/selection/Selection"

# this is a very simplistic approach to show search result
# TODO: needs proper styling
module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g

    @listenTo @g.user, "change:searchText", (model, prop) ->
      @search prop
      @render()
    @sel = []
    @selPos = 0

  events:
    "scroll": "_sendScrollEvent"

  render: ->
    @renderSubviews()

    @el.className = "biojs_msa_searchresult"
    searchText = @g.user.get("searchText")
    if searchText? and searchText.length > 0
      if @sel.length is 0
        @el.textContent = "no selection found"
      else
        @resultBox = k.mk "div"
        @resultBox.className = "biojs_msa_searchresult_ovbox"
        @updateResult()
        @el.appendChild @resultBox
        @el.appendChild @buildBtns()
    @

  updateResult: ->
      text = "search pattern: " + @g.user.get("searchText")
      text += ", selection: " + (@selPos + 1)
      seli = @sel[@selPos]
      text += " ("
      text += seli.get("xStart") + " - " + seli.get("xEnd")
      text += ", id: " + seli.get("seqId")
      text += ")"
      @resultBox.textContent = text

  buildBtns: ->
    prevBtn = k.mk "button"
    prevBtn.textContent = "Prev"
    prevBtn.addEventListener "click", =>
      @moveSel -1

    nextBtn = k.mk "button"
    nextBtn.textContent = "Next"
    nextBtn.addEventListener "click", =>
      @moveSel 1

    allBtn = k.mk "button"
    allBtn.textContent = "All"
    allBtn.addEventListener "click", =>
      @g.selcol.reset @sel

    searchrow = k.mk "div"
    searchrow.appendChild prevBtn
    searchrow.appendChild nextBtn
    searchrow.appendChild allBtn
    searchrow.className = "biojs_msa_searchresult_row"
    searchrow

  moveSel: (relDist) ->
    selNew = @selPos + relDist
    if selNew < 0 or selNew >= @sel.length
      return -1
    else
      @focus selNew
      @selPos = selNew
      @updateResult()

  focus: (selPos) ->
    seli = @sel[selPos]
    leftIndex = seli.get "xStart"
    @g.zoomer.setLeftOffset leftIndex
    @g.selcol.reset [seli]

  search: (searchText) ->
    # marks all hits
    search = new RegExp searchText, "gi"
    newSeli = []
    leftestIndex = origIndex = 100042

    @model.each (seq) ->
      strSeq = seq.get("seq")
      while match = search.exec strSeq
        index = match.index
        args = {xStart: index, xEnd: index + match[0].length - 1, seqId:
          seq.get("id")}
        newSeli.push new sel.possel(args)
        leftestIndex = Math.min index, leftestIndex

    @g.selcol.reset newSeli

    # safety check + update offset
    leftestIndex = 0 if leftestIndex is origIndex
    @g.zoomer.setLeftOffset leftestIndex

    @sel = newSeli
