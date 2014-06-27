define ["cs!input/fasta", "cs!msa/msa"], (Fasta, MSA) ->

  stage = null

  xStart = 100
  yStart = 0

  module "tiles.zooming",
    setup: ->
      stop()
      Fasta.read "../dummy/foo.fasta", (seqs) ->
        msa = new MSA "msa", seqs, {speed: true}
        stage = msa.stage
        stage.tileSize = 200
        stage.viewportX = xStart
        stage.viewportY = yStart
        stage.dblClickVx = 2
        stage.dblClickVy = 2
        start()

  test "zoom in middle", ->
    stage._onDblClick {offsetX: stage.canvas.width / 2, offsetY: stage.canvas.height / 2}
    equal stage.viewportX, xStart * 2, "xView"
    equal stage.viewportY, yStart * 2, "yView"

  test "zoom in and out", ->
    stage._onDblClick {offsetX: stage.canvas.width / 2, offsetY: stage.canvas.height / 2}
    stage._onContextMenu {offsetX: stage.canvas.width / 2, offsetY: stage.canvas.height / 2}
    equal stage.viewportX, xStart, "xView"
    equal stage.viewportY, yStart, "yView"

  test "zoom in right", ->
    stage._onDblClick {offsetX: stage.canvas.width, offsetY: stage.canvas.height}
    equal stage.viewportX, (xStart + stage.canvas.width / 2) * 2, "xView"
    equal stage.viewportY, (13) * 2, "yView"
