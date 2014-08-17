Sequence = require "./Sequence"
Collection = require("backbone").Collection

module.exports = SeqManager = Collection.extend
  model: Sequence

  getMaxLength: () ->
    @max (seq) -> seq.get("seq").length
