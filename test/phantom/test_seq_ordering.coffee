MSA = require "../../src/msa"
Seq = require "../../src/model/Sequence"
_ = require "underscore"
assert = require("chai").assert
equal = assert.deepEqual

suite "test ordering"

s = {}

reduceSeqs = (p) ->
  res = []
  for seq,index in p
    seq = p.at(index)
    res.push seq.get "id"
  res


beforeEach "setup test array", ->
  seqs = []
  seqs.push new Seq
    seq: "AGET"
    name: "cname"
    id: "uni3"
  seqs.push new Seq
    seq: "EBFG"
    name: "ename"
    id: "uni2"
  seqs.push new Seq
    seq: "HFGF"
    name: "dname"
    id: "uni5"
  seqs.push new Seq
    seq: "ZAAA"
    name: "aname"
    id: "uni1"
  seqs.push new Seq
    seq: "TCCH"
    name: "bname"
    id: "uni4"

  # add to msa
  msa = new MSA
    seqs: seqs

  #console.log msa.el
  s = msa.seqs

test "should order by default after ", ->
  s.comparator = (seq) -> seq.get "id"
  s.sort()
  equal reduceSeqs(s), ["uni1","uni2","uni3", "uni4", "uni5" ]


test "should order reverse by id", ->
  s.comparator = (a, b) ->
    - a.get("id").localeCompare(b.get("id"))
  s.sort()
  equal reduceSeqs(s), ["uni5","uni4","uni3", "uni2", "uni1" ]


test "should order after name", ->
  s.comparator = (seq) -> seq.get "name"
  s.sort()
  equal reduceSeqs(s), ["uni1","uni4","uni3", "uni5", "uni2" ]

test "should order after name [reverse]", ->
  s.comparator = (a, b) ->
    - a.get("name").localeCompare(b.get("name"))
  s.sort()
  equal reduceSeqs(s), ["uni2","uni5","uni3", "uni4", "uni1" ]


test "should order after sequence", ->
  s.comparator = (seq) -> seq.get "seq"
  s.sort()
  equal reduceSeqs(s), ["uni3","uni2","uni5", "uni4", "uni1" ]


test "should order after sequence [reverse]", ->
  s.comparator = (a, b) ->
    - a.get("seq").localeCompare(b.get("seq"))
  s.sort()
  equal reduceSeqs(s), ["uni1","uni4","uni5", "uni2", "uni3" ]

