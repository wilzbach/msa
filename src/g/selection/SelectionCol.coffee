sel = require "./Selection"
_ = require "underscore"

Collection = require("backbone").Collection
# holds the current user selection
module.exports = SelectionManager = Collection.extend

  model: sel.sel

  initialize: (data, opts) ->
    @g = opts.g

    @listenTo @g, "residue:click", (e) ->
      @_handleE e.evt, new sel.possel
        xStart: e.rowPos
        xEnd: e.rowPos
        seqId: e.seqId

    @listenTo @g, "row:click", (e) ->
      @_handleE e.evt, new sel.rowsel
        xStart: e.rowPos
        xEnd: e.rowPos
        seqId: e.seqId

    @listenTo @g, "column:click", (e) ->
      @_handleE e.evt, new sel.columnsel
        xStart: e.rowPos
        xEnd: e.rowPos + e.stepSize - 1

    @listenTo @, "add reset", (e) ->
      @_reduceColumns()

  getSelForRow: (seqId) ->
    @filter (el) -> el.inRow seqId

  getSelForColumns: (rowPos) ->
    @filter (el) -> el.inColumn rowPos

  # @returns array of all selected residues for a row
  getBlocksForRow: (seqId, maxLen) ->
    selis = @filter (el) -> el.inRow seqId
    blocks = []
    for seli in selis
      if seli.attributes.type is "row"
        blocks = [0..maxLen]
        break
      else
        blocks = blocks.concat [seli.attributes.xStart .. seli.attributes.xEnd]
    blocks

  getAllColumnBlocks: (maxLen) ->
    blocks = []
    for seli in (@filter (el) -> el.get('type') is "column")
      blocks = blocks.concat [seli.attributes.xStart..seli.attributes.xEnd]
    return blocks

  # inverts the current selection for columns
  # @param rows [Array] all available seqId
  invertRow: (rows) ->
    selRows = @where(type:"row")
    selRows = _.map selRows, (el) -> el.attributes.seqId
    inverted = _.filter rows, (el) ->
      return false if selRows.indexOf(el) >= 0 # existing selection
      true
    # mass insert
    s = []
    for el in inverted
      s.push new sel.rowsel(seqId:el)
    console.log s
    @reset s

  # inverts the current selection for rows
  # @param rows [Array] all available rows (0..max.length)
  invertCol: (columns) ->
    selColumns = @where(type:"column")
    selColumns = _.reduce selColumns, (memo,el) ->
      memo.concat [el.attributes.xStart .. el.attributes.xEnd]
    , []
    inverted = _.filter columns, (el) ->
      if selColumns.indexOf(el) >= 0
        # existing selection
        return false
      true
    # mass insert
    return if inverted.length == 0
    s = []
    console.log inverted
    xStart = xEnd = inverted[0]
    for el in inverted
      if xEnd + 1 is el
        # contiguous
        xEnd = el
      else
        # gap between
        s.push new sel.columnsel(xStart:xStart, xEnd: xEnd)
        xStart = xEnd = el
    # check for last gap
    s.push new sel.columnsel(xStart:xStart, xEnd: inverted[inverted.length - 1]) if xStart isnt xEnd
    @reset s

  _handleE: (e, selection) ->
    if e.ctrlKey or e.metaKey
      @add selection
    else
      @reset [selection]

  # experimental reduce method for columns
  _reduceColumns: ->
    @each (el, index, arr) ->
      cols = _.filter arr, (el) -> el.get('type') is 'column'
      xStart = el.get('xStart')
      xEnd = el.get('xEnd')

      lefts = _.filter cols, (el) -> el.get('xEnd') is (xStart - 1)
      for left in lefts
        left.set 'xEnd', xStart

      rights = _.filter cols, (el) -> el.get('xStart') is (xEnd + 1)
      for right in rights
        right.set 'xStart', xEnd

      if lefts.length > 0 or rights.length > 0
        console.log "removed el"
        el.collection.remove el
