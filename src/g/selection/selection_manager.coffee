SelectionList = require "./selectionlist"
selection = require "./"

Model = require("backbone").Model
# holds the current user selection
module.exports = SelectionManager = Model.extend

  initialize: (data) ->
    @g = data.g

    #@.set "selection", []

    return

    # residues
    @msa.on "residue:click", (data) =>
      selPos = new selection.PositionSelect(@msa, data.seqId, data.rowPos)
      @handleSel selPos, data.evt
    @msa.on "residue:mouseover", (data) ->
      @msa.selmanager.changeSel new selection.PositionSelect(@msa, data.seqId,
          evt.target.rowPos)
    @msa.on "residue:mouseout", (data) ->

    # rows
    # click is done by the label
    @msa.on "row:click", (data) ->
    @msa.on "row:mouseover", (data) ->
    @msa.on "row:mouseout", (data) ->

    # column
    # click is done by the marker
    @msa.on "column:click", (data) ->
    @msa.on "column:mouseover", (data) ->
    @msa.on "column:mouseout", (data) ->


    #@msa.on "mouseout" =>


  changeSel: (sel) ->
    # remove old
    @currentSelection.deselect() if @currentSelection?

    # apply now
    @currentSelection = sel
    sel.select() if sel?

    # broadcast to event handler
    @msa.trigger "onSelectionChanged",sel

  # detects shiftKey
  handleSel: (sel, evt) ->
    if evt.ctrlKey or evt.metaKey
      # check whether we already have a list
      if @currentSelection?.isList?
        selList = @currentSelection
        @currentSelection = undefined
      else
        # create new list
        selList = new SelectionList()

      # add
      selList.addSelection sel
      sel = selList

    @changeSel sel

  cleanup: ->
    @changeSel(undefined)

  # TODO: split int two methods
  getInvolvedSeqs: ->
    if @currentSelection?
      name = @currentSelection.__proto__.constructor.name
      return @msa.seqs if name is "VerticalSelection"
      return [@msa.seqs[@currentSelection.id]] if name is "HorizontalSelection" or name is
      "PositionSelection"

      if name is "SelectionList"
        seqs = []
        for key,sel of @currentSelection._sels
          name = sel.__proto__.constructor.name
          if name is "HorizontalSelection" or name is "PositionSelection"
            seqs.push @msa.seqs[sel.id]
        return seqs
    else
      console.log "no involved seqs"
      return undefined
