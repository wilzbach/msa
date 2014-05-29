define [], ->
  class Seq
    meta: {}
    constructor: (@seq, @name, @id) ->

    # Returns the reverse complement sequence.
    #reverse_complement: ->
    #  @seq.split("").reverse().join("")

  return Seq
