Benchmark = require 'benchmark'
suite = new Benchmark.Suite
MSA = require "../../src/msa"
Seq = require "../../src/model/Sequence"

buildSeqs = (num,len) ->
  seqs = []
  for i in [0..num] by 1
    seqs.push new Seq
      seq: Array.apply(null, new Array(len)).map(String.prototype.valueOf,"A")
      name: "cname" + i
      id: "uni" + i
  seqs

# removes the div element from DOM
# and creates a new empty DOM element
cleanDiv = (name) ->
  div = document.getElementById name
  parent = div.parentNode
  div.parentNode.removeChild div
  newDiv = document.createElement "div"
  newDiv.id = name
  parent.appendChild newDiv

# run async
suite.add "MSA#initrender", ->
  cleanDiv "msa"
  msa = new MSA {seqs: buildSeqs(10,100), el: "#msa" }
  msa.render()
.add "MSA#10x1000", ->
  msa = new MSA {seqs: buildSeqs(10,1000), el: "#msa"}
  msa.render()
.add "MSA#100x100", ->
  msa = new MSA {seqs: buildSeqs(10,1000), el: "#msa"}
  msa.render()
.add "MSA#1000x1000", ->
  msa = new MSA {seqs: buildSeqs(10,1000), el: "#msa"}
  msa.render()
.on "cycle", (event) ->
  console.log String(event.target)
.on "complete", ->
  console.log "Fastest is " + @filter("fastest").pluck("name")
.run async: true
