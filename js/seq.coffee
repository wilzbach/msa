define [], () ->
  class Seq
    constructor: (@seq) ->

    # Returns the reverse complement sequence.
    reverse_complement: ->
      @seq.split("").reverse().join("")

    # Returns the RNA sequence from a DNA sequence.
    transcribe: ->
      return @seq

    # Returns the DNA sequence from an RNA sequence.
    back_transcribe: ->
      return @seq

    # Turns a nucleotide sequence into a protein sequence.
    #translate(self, table='Standard', stop_symbol='*', to_stop=False, cds=False)
    translate: ->
      return @seq

    # Return a copy of the sequence without the gap character
    ungap: ->
      return @seq

  return Seq
