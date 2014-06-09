define ["msa/utils"], (Utils) ->
  class Colorator

    scheme: "taylor"

    constructor: () ->

    colorResidue: (aminoGroup, tSeq, pos) =>

      # TODO: use CSS classes for that
      aminoGroup.className = "biojs_msa_single_residue"
      residue = tSeq.seq.charAt(pos)
      colorResidue = "ffffff"
      if @scheme is "taylor"
        colorResidue = Colorator.taylorColors[residue]
      else if @scheme is "zappo"
        colorResidue = Colorator.zappoColors[residue]
      else if @scheme is "hydrophobicity"
        colorResidue = Colorator.hydrophobicityColors[residue]
      else
        colorResidue = Colorator.taylorColors[residue]

      colorResidue = "ffffff"  if typeof colorResidue is "undefined"
      colorInHex = Utils.hex2rgb(colorResidue)
      aminoGroup.color = colorInHex
      aminoGroup.style.backgroundColor = Utils.rgba(colorInHex, 0.3)
      aminoGroup.style.borderTop = "none"
      aminoGroup.style.borderLeft = "none"
      aminoGroup.style.borderRight = "none"
      aminoGroup.style.borderBottom = "none"

      #rect.setShadowOpacity(0.0);
      aminoGroup.style.color = "black"
      return

    colorSelectedResidue: (aminoGroup, tSeq, pos) =>
      color = aminoGroup.color

      #aminoGroup.style.borderTop = "thick solid #0000FF";
      #aminoGroup.style.borderBottom = "thick solid #0000FF";
      aminoGroup.style.backgroundColor = Utils.rgba(color, 0.8) \
        unless @reverseColoring(aminoGroup)
      return


    #aminoGroup.className +=  " shadowed";
    reverseColoring: (aminoGroup) ->
      if aminoGroup.color.r is 255 and aminoGroup.color.g is 255 \
          and aminoGroup.color.b is 255
        color = aminoGroup.color
        aminoGroup.style.color = Utils.rgba(color, 0.8)
        color = Utils.hex2rgb("000000")
        aminoGroup.style.backgroundColor = Utils.rgba(color, 0.8)
        true
      else
        false

    colorSelectedResidueColumn: (aminoGroup, tSeq, pos) =>
      color = aminoGroup.color
      aminoGroup.style.backgroundColor = Utils.rgba(color, 0.8) \
        unless @reverseColoring(aminoGroup)


    #aminoGroup.style.borderLeft = "thick solid #0000FF";
    #aminoGroup.style.borderRight = "thick solid #0000FF";
    colorSelectedResidueSingle : (aminoGroup, tSeq, pos) ->
      color = aminoGroup.color
      aminoGroup.style.backgroundColor = Utils.rgba(color, 0.8) \
        unless @reverseColoring(aminoGroup)

      #
      #         aminoGroup.style.borderTop = "thick solid #0000FF";
      #         aminoGroup.style.borderLeft = "thick solid #0000FF";
      #         aminoGroup.style.borderRight = "thick solid #0000FF";
      #         aminoGroup.style.borderBottom = "thick solid #0000FF";
      #
      aminoGroup.className += " shadowed"

    colorColumn: (columnGroup, columnPos) ->
      columnGroup.style.backgroundColor = "transparent"

    colorSelectedColumn: (columnGroup, columnPos) ->
      columnGroup.style.backgroundColor = "red"

    setScheme: (name) ->
      @scheme = name
      @scheme = name.toLowerCase()

    @taylorColors: {
      V: "99ff00"
      I: "66ff00"
      L: "33ff00"
      F: "00ff66"
      Y: "00ffcc"
      W: "00ccff"
      H: "0066ff"
      R: "0000ff"
      K: "6600ff"
      N: "cc00ff"
      Q: "ff00cc"
      E: "ff0066"
      D: "ff0000"
      S: "ff3300"
      T: "ff6600"
      G: "ff9900"
      P: "ffcc00"
      C: "ffff00"
    }

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
