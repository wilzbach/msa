Utils = require "./utils/general"
Row = require "./model/row"

module.exports =
  # provides high-level abstraction
  # for working with the sequence stage
  class SeqManager

    constructor: () ->
      @seqs = {}

    # adds multiple seqs
    addSeqs: (tSeqs) ->
      # check whether array or single seq
      unless tSeqs.id?
        for e in tSeqs
          @addSeq e
      else
        @addSeq tSeqs

    # add one sequence
    addSeq: (tSeq) ->
      #@msa.trigger "seq:add", tSeq
      @seqs[tSeq.id] = new Row tSeq, undefined

    # removes a seq
    # TODO: not tested
    removeSeq: (id) ->
      @seqs[id].layer.destroy()
      delete seqs[id]
      # TODO: reorder
      # TODO: maybe redraw ?
