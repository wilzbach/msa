define ["cs!input/generic_reader"], (GenericReader) ->
  class Fasta extends GenericReader

    constructor: (@text) ->
      console.log("hihi")

    toString:() ->
      console.log("hi")
      return @text
