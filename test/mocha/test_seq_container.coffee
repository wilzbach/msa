Ordering = require "../../src/ordering"
StageContainer = require "../../src/stage/stageContainer"
Seq = require("biojs-model").seq
assert = require("chai").assert
equal = assert.deepEqual

suite "test ordering"

seqs = []
ordering = undefined

beforeEach "setup test array", ->
  seqs = []
  seqs.push new Seq("AGET", "cname", "uni3" )
  seqs.push new Seq("EBFG", "ename", "uni2" )
  seqs.push new Seq("HFGF", "dname", "uni5" )
  seqs.push new Seq("ZAAA", "aname", "uni1" )
  seqs.push new Seq("TCCH", "bname", "uni4" )

  # simulate that they are added
  stage = new StageContainer()
  stage.addSeqs seqs
  seqs = stage.seqs

  ordering = new Ordering()

# custom user fun
# looks at the second char of the sequence
customFun = (seqs, ordering) ->
  ordering.sort (a, b) ->
    nameA = seqs[a].tSeq.seq[1]
    nameB = seqs[b].tSeq.seq[1]
    if nameA < nameB
      -1
    else if nameA > nameB
      1
    else
      0


test "should order by default after ", ->
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni1","uni2","uni3", "uni4", "uni5" ]


test "should order reverse by id", ->
  sortedSeqs = ordering.calcSeqOrder seqs
  ordering.setReverse true
  equal sortedSeqs, ["uni1","uni2","uni3", "uni4", "uni5" ]


test "should order after name", ->
  ordering.setSort Ordering.orderName
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni1","uni4","uni3", "uni5", "uni2" ]

test "should order after name [reverse]", ->
  ordering.setSort Ordering.orderName
  ordering.setReverse true
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni2","uni5","uni3", "uni4", "uni1" ]


test "should order after sequence", ->
  ordering.setSort Ordering.orderSeq
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni3","uni2","uni5", "uni4", "uni1" ]


test "should order after sequence [reverse]", ->
  ordering.setSort Ordering.orderSeq
  ordering.setReverse true
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni1","uni4","uni5", "uni2", "uni3" ]

test "should allow a custom function", ->

  ordering.setSort customFun
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni1","uni2","uni4", "uni5", "uni3" ]

test "should allow a custom function [reverse]", ->

  ordering.setSort customFun
  ordering.setReverse true
  sortedSeqs = ordering.calcSeqOrder seqs
  equal sortedSeqs, ["uni3","uni5","uni4", "uni2", "uni1" ]