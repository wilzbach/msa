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

  # @returns array with all columns being selected
  # example: 0-4... 12-14 selected -> [0,1,2,3,4,12,13,14]
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

  # method to decide whether to start a new selection
  # or append to the old one (depending whether CTRL was pressed)
  _handleE: (e, selection) ->
    if e.ctrlKey or e.metaKey
      @add selection
    else
      @reset [selection]

