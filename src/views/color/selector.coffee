# basics
Taylor = require "./taylor"
Zappo= require "./zappo"
Hydro= require "./hydrophobicity"

Clustal = require "./clustal"
Clustal2 = require "./clustal2"

Buried = require "./buried"
Cinema = require "./cinema"
Nucleotide  = require "./nucleotide"
Helix  = require "./helix"
Lesk  = require "./lesk"
Mae = require "./mae"
Purine = require "./purine"
Strand = require "./strand"
Turn = require "./turn"

module.exports = Colors =

  mapping:
    taylor: Taylor
    zappo: Zappo
    hydro: Hydro
    clustal: Clustal
    clustal2: Clustal2
    buried: Buried
    cinema: Cinema
    nucleotide: Nucleotide
    helix: Helix
    lesk: Lesk
    mae: Mae
    purine: Purine
    strand: Strand
    turn: Turn

  getColor: (g) ->
    scheme = g.colorscheme.get "scheme"

    color = Colors.mapping[scheme]

    if color is undefined
      console.log "warning. no color scheme found."
      color = {}

    return color
