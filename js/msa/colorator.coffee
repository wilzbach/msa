define ["msa/utils"], (Utils) ->
  class Colorator

    scheme: "taylor"

    constructor: () ->

    colorResidue: (aminoGroup, tSeq, pos) =>

      aminoGroup.className = "biojs_msa_single_residue"

      residue = Colorator.getResidue tSeq,pos
      aminoGroup.className += " biojs-msa-aa-" + residue

    colorSelectedResidue: (aminoGroup, tSeq, pos) =>

      aminoGroup.className = "biojs_msa_single_residue"
      residue = Colorator.getResidue tSeq,pos
      aminoGroup.className += " biojs-msa-aa-" + residue + "-selected"

    colorSelectedResidueColumn: (aminoGroup, tSeq, pos) =>
      aminoGroup.className = "biojs_msa_single_residue"
      residue = Colorator.getResidue tSeq,pos
      aminoGroup.className += " biojs-msa-aa-" + residue + "-selected"


    colorSelectedResidueSingle : (aminoGroup, tSeq, pos) ->
      aminoGroup.className = "biojs_msa_single_residue"
      residue = Colorator.getResidue tSeq,pos
      aminoGroup.className += " biojs-msa-aa-" + residue + "-selected"
      aminoGroup.className += " shadowed"

    colorColumn: (columnGroup, columnPos) ->
      columnGroup.style.backgroundColor = "transparent"
      columnGroup.style.color = ""

    colorSelectedColumn: (columnGroup, columnPos) ->
      columnGroup.style.backgroundColor =
        Utils.rgba(Utils.hex2rgb("ff0000"),1.0)
      columnGroup.style.color = "white"

    colorRow: (rowGroup, rowId) ->
      rowGroup.className = "biojs_msa_sequence_block"
      rowGroup.className += " biojs-msa-schemes-" + @scheme


    setScheme: (name) ->
      @scheme = name
      @scheme = name.toLowerCase()

    @getResidue: (tSeq,pos) ->
      residue = tSeq.seq.charAt(pos)
      if residue is "-"
        "Gap"
      else
        residue

    @zappoColors: {
      V: "ff6666"
      I: "ff6666"
      L: "ff6666"
      A: "ff6666"
      M: "ff6666"
      F: "ff9900"
      Y: "ff9900"
      W: "ff9900"
      H: "cc0000"
      R: "cc0000"
      K: "cc0000"
      E: "33cc00"
      D: "33cc00"
      S: "3366ff"
      T: "3366ff"
      N: "3366ff"
      Q: "3366ff"
      G: "cc33cc"
      P: "cc33cc"
      C: "ffff00"
    }

    @hydrophobicityColors: {
      I: "ff0000"
      V: "f60009"
      L: "ea0015"
      F: "cb0034"
      C: "c2003d"
      M: "b0004f"
      A: "ad0052"
      G: "6a0095"
      X: "680097"
      T: "61009e"
      S: "5e00a1"
      W: "5b00a4"
      Y: "4f00b0"
      P: "4600b9"
      H: "1500ea"
      E: "0c00f3"
      Z: "0c00f3"
      Q: "0c00f3"
      D: "0c00f3"
      B: "0c00f3"
      N: "0c00f3"
      K: "0000ff"
      R: "0000ff"
    }
