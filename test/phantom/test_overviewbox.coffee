MSA = require "../../src/msa"
Seq = require "../../src/model/Sequence"
_ = require "underscore"
assert = require("chai").assert
equal = assert.deepEqual

suite "test overviewbox"

s = {}
box = {}
zoomer = {}

reduceSeqs = (p) ->
  res = []
  for seq,index in p
    seq = p.at(index)
    res.push seq.get "id"
  res


beforeEach "setup test array", ->
  seqs = []
  for i in [0..9] by 1
    seqs.push new Seq
      seq:
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
      name: "cname" + i
      id: "uni" + i

  zoomer =
    boxRectHeight: 5
    boxRectWidth: 5

  vis =
    overviewbox: true

  # add to msa
  msa = new MSA
    seqs: seqs
    zoomer: zoomer
    vis: vis

  s = msa
  box = msa.getView('stage').getView('overviewbox')

test "should trigger an selection event", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    offsetI = 2
    equal e.length, 3
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: 3, seqId: "uni" + (i + offsetI)}
    triggered = true
  box._onmousedown {offsetX: 5, offsetY: 10}
  box._onmouseup {offsetX: 16, offsetY: 20}
  assert.isTrue triggered

test "should trigger only one field", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    offsetI = 1
    equal e.length, 1
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: 1, seqId: "uni" + (i + offsetI)}
    triggered = true
  box._onmousedown {offsetX: 6, offsetY: 9}
  box._onmouseup {offsetX: 7, offsetY: 8}

test "edge case: left x", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    offsetI = 1
    equal e.length, 2
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 0, xEnd: 1, seqId: "uni" + (i + offsetI)}
    triggered = true
  box._onmousedown {offsetX: 6, offsetY: 9}
  box._onmouseup {offsetX: -7, offsetY: 11}

test "edge case: x right", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    offsetI = 0
    equal e.length, 2
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: s.seqs.getMaxLength(), seqId: "uni" + (i + offsetI)}
    triggered = true
  box._onmousedown {offsetX: 6, offsetY: -9}
  box._onmouseup {offsetX: 7000, offsetY: 8}

test "edge case: y bottom", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    offsetI = 1
    equal e.length, s.seqs.length - 1
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 0, xEnd: 1, seqId: "uni" + (i + offsetI)}
    triggered = true
  box._onmousedown {offsetX: 6, offsetY: 9}
  box._onmouseup {offsetX: -7, offsetY: 2000}
