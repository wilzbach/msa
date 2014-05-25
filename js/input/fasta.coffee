define ["cs!input/generic_reader"], (GenericReader) ->
  class Fasta
    constructor: (@url) ->
      #@text = new GenericReader().fetch(@url)

    toString: ->
      return "foo"
      #return @text.text

  return Fasta
