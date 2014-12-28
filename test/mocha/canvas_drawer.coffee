CanvasDrawSeq = require "../../src/views/canvas/CanvasSeqDrawer"
Seq = require "../../src/model/Sequence"
SeqCol = require "../../src/model/SeqCollection"
Zoomer = require "../../src/g/zoomer"
assert = require("chai").assert
equal = assert.deepEqual
sinon = require "sinon"

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

a = {}

suite "seqDrawer"

beforeEach "setup canvas", ->
 a.model = new SeqCol buildSeqs(20,500)
 a.g = {}
 a.ctx = sinon.stub()
 columnWidth = rowHeight = 10
 a.g.zoomer = new Zoomer {rowHeight: rowHeight, columnWidth: columnWidth}, g:{}, model: a.model
 a.d = new CanvasDrawSeq a.g, a.ctx, a.model,
   width: 200
   height: 200
   color: "black"
   cache: undefined

test "correct start seq", ->
  equal [0,-0], a.d.getStartSeq()

  a.g.zoomer.set "_alignmentScrollTop", 20
  equal [2,-0], a.d.getStartSeq()

  a.g.zoomer.set "_alignmentScrollTop", 29
  equal [2,-9], a.d.getStartSeq()

  a.g.zoomer.set "_alignmentScrollTop", 5
  equal [0,-5], a.d.getStartSeq()

test "start: out of bounds", ->
  a.g.zoomer.set "_alignmentScrollTop", -10
  equal [0,-0], a.d.getStartSeq()

test "correct start seq with features", ->
  a.model.at(0).set "height", 2
  equal [0,-0], a.d.getStartSeq()
  a.g.zoomer.set "_alignmentScrollTop", 19
  equal [0,-19], a.d.getStartSeq()
  a.g.zoomer.set "_alignmentScrollTop", 21
  equal [1,-1], a.d.getStartSeq()
  a.g.zoomer.set "_alignmentScrollTop", 31
  equal [2,-1], a.d.getStartSeq()
