define ["cs!input/generic_reader"], (GenericReader) ->
  class Fasta extends GenericReader

    toString: ->
      return @_fetch()

  return Fasta
