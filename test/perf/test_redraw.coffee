Benchmark = require 'benchmark'
suite = new Benchmark.Suite
MSA = require "../../src/msa"
Seq = require "../../src/model/Sequence"

buildSeqs = (num,len) ->
  seqs = []
  letters = ["A", "C", "G", "T"]
  for i in [0..num] by 1
    seqs.push new Seq
      seq: Array.apply(null, new
        Array(len)).map(String.prototype.valueOf,letters[Math.floor(Math.random() * 4)])
      name: "cname" + i
      id: "uni" + i
  seqs

m = new MSA {seqs: buildSeqs(20,500), el: "#msa" }
m.render()

# run async
suite
.add "MSA#movePos", ->
  left = m.g.zoomer.get "_alignmentScrollLeft"
  if left > 200
    m.g.zoomer.set '_alignmentScrollLeft', 100
  else
    m.g.zoomer.set '_alignmentScrollLeft', 300
.add "MSA#redrawColor", ->
  color = m.g.colorscheme.get "scheme"
  if color is "zappo"
    m.g.colorscheme.set "scheme", "taylor"
  else
    m.g.colorscheme.set "scheme", "zappo"
.on "cycle", (event) ->
  console.log String(event.target)
.on "complete", ->
  console.log "Fastest is " + @filter("fastest").pluck("name")
.run async: true
