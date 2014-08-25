view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
_ = require "underscore"

module.exports = FilterMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menuFilter = new MenuBuilder("Filter")
    menuFilter.addNode "Hide columns by threshold",(e) =>
      threshold = prompt "Enter threshold (in percent)", 20
      threshold = threshold / 100
      maxLen = @model.getMaxLength()
      hidden = []
      conserv = @g.columns.get("conserv")
      for i in [0.. maxLen - 1]
        if conserv[i] < threshold
          hidden.push i
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Hide columns by selection", =>
      hiddenOld = @g.columns.get "hidden"
      hidden = hiddenOld.concat @g.selcol.getAllColumnBlocks @model.getMaxLength()
      @g.selcol.reset []
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Hide columns by gaps", =>
      threshold = prompt "Enter threshold (in percent)", 20
      threshold = threshold / 100
      maxLen = @model.getMaxLength()
      hidden = []
      for i in [0.. maxLen - 1]
        gaps = 0
        total = 0
        @model.each (el) ->
          gaps++ if el.get('seq')[i] is "-"
          total++
        gapContent = gaps / total
        if gapContent > threshold
          hidden.push i
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Hide seqs by identity", =>
      threshold = prompt "Enter threshold (in percent)", 20
      threshold = threshold / 100
      @model.each (el) ->
        if el.get('identity') < threshold
          el.set('hidden', true)

    menuFilter.addNode "Hide seqs by gaps", =>
      threshold = prompt "Enter threshold (in percent)", 40
      @model.each (el,i) ->
        seq = el.get('seq')
        gaps = _.reduce seq, ((memo, c) -> memo++ if c is '-';memo),0
        console.log gaps
        if gaps >  threshold
          el.set('hidden', true)

    menuFilter.addNode "Reset", =>
      @g.columns.set "hidden", []
      @model.each (el) ->
        if el.get('hidden')
          el.set('hidden', false)

    @el = menuFilter.buildDOM()
    @
