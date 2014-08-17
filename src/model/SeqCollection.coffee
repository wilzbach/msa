Sequence = require "./Sequence"
Collection = require("backbone").Collection

module.exports = SeqManager = Collection.extend
  model: Sequence

  # gives the max length of all sequences
  getMaxLength: () ->
    @max((seq) -> seq.get("seq").length).get("seq").length
