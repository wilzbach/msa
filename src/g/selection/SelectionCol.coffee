sel = require "./Selection"
_ = require "underscore"

Collection = require("backbone").Collection
# holds the current user selection
module.exports = SelectionManager = Collection.extend

  model: sel.sel

  initialize: (data, opts) ->
    @g = opts.g

    @listenTo @g, "residue:click", (e) ->
      @add new sel.possel
        xStart: e.rowPos
        xEnd: e.rowPos
        seqId: e.seqId

    @listenTo @g, "row:click", (e) ->
      @add new sel.rowsel
        xStart: e.rowPos
        xEnd: e.rowPos
        seqId: e.seqId

    @listenTo @g, "column:click", (e) ->
      @add new sel.columnsel
        xStart: e.rowPos
        xEnd: e.rowPos

  getSelForRow: (seqId) ->
    @filter (el) -> el.inRow seqId

  getSelForColumns: (rowPos) ->
    @filter (el) -> el.inColumn seqId

# assumes there is no overlapping selection
#  getColForRow: (seqId) ->
#    c = _.chain(@getSelForRow seqId)
#    rows = c.findWhere {type:"row"}
#    # full match
#    if row.length > 0
#      return -1
#    else
#      ch = ch.invoke("getCols")
#      ch.value()
#      #ch.reduce (memo,el) ->
#      #  return -1 memo is -1 or el -1
#      #  # one is part of the other
#      #  return memo if memo[0] < el[0] && el[1] < memo[1]
#      #  return el if el[0] < memo[0] && memo[1] < el[1]
