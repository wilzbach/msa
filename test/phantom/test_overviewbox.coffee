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

_onmousedown = (e) ->
  e.offsetX = e.pageX
  e.offsetY = e.pageY
  box._onmousedown e

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
  box = msa.getView('stage').getView('overviewBox')

test "should trigger an selection event", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    pageI = 2
    equal e.length, 3
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: 3, seqId: "uni" + (i + pageI)}
    triggered = true
  _onmousedown {pageX: 5, pageY: 10}
  box._onmouseup {pageX: 16, pageY: 20}
  assert.isTrue triggered

test "should trigger only one field", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    pageI = 1
    equal e.length, 1
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: 1, seqId: "uni" + (i + pageI)}
    triggered = true
  _onmousedown {pageX: 6, pageY: 9}
  box._onmouseup {pageX: 7, pageY: 8}

test "edge case: left x", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    pageI = 1
    equal e.length, 2
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 0, xEnd: 1, seqId: "uni" + (i + pageI)}
    triggered = true
  _onmousedown {pageX: 6, pageY: 9}
  box._onmouseup {pageX: -7, pageY: 11}

test "edge case: x right", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    pageI = 0
    equal e.length, 2
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 1, xEnd: s.seqs.getMaxLength() - 1, seqId: "uni" + (i + pageI)}
    triggered = true
  _onmousedown {pageX: 6, pageY: -9}
  box._onmouseup {pageX: 7000, pageY: 8}

test "edge case: y bottom", ->
  triggered = false
  s.g.selcol.on "reset", (e) ->
    pageI = 1
    equal e.length, s.seqs.length - 1
    for i in [0.. e.length - 1]
      equal e.at(i).toJSON(), {type: "pos", xStart: 0, xEnd: 1, seqId: "uni" + (i + pageI)}
    triggered = true
  _onmousedown {pageX: 6, pageY: 9}
  box._onmouseup {pageX: -7, pageY: 2000}
