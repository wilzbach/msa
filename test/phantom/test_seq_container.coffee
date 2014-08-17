MSA = require "../../src/msa"
Seq = require "../../src/model/Sequence"
assert = require("chai").assert
equal = assert.deepEqual

suite "test dom stage"

seqs = []
msa = undefined

beforeEach "setup sequences", ->
  seqs = []
  seqs.push new Seq("AGET", "cname", "uni3" )
  seqs.push new Seq("EBFG", "ename", "uni2" )
  seqs.push new Seq("HFGF", "dname", "uni5" )
  seqs.push new Seq("ZAAA", "aname", "uni1" )
  seqs.push new Seq("TCCH", "bname", "uni4" )

  # simulate that they are added
  msa = new MSA
    seqs:seqs

test "should draw a DOM container", ->
  msa.render()
