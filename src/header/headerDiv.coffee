Utils = require "../utils/general"

module.exports =  (msa, opts) ->
  headerDiv = opts.element
  Utils.removeAllChilds headerDiv

  # check for offset
  unless msa.config.visibleElements.labels
    headerDiv.style.paddingLeft = "0px"
  else
    headerDiv.style.paddingLeft = "#{msa.zoomer.seqOffset}px"

  # using fragments is the fastest way
  # try to minimize DOM updates as much as possible
  # http://jsperf.com/innerhtml-vs-createelement-test/6
  residueGroup = document.createDocumentFragment()
  n = 0

  nMax = msa.zoomer.len
  if nMax is 0
    nMax = msa.zoomer.getMaxLength

  while n < nMax
    residueSpan = document.createElement("span")
    opts.createElement { target: residueSpan, rowPos: n}
    residueSpan.style.width = msa.zoomer.columnWidth * opts.stepSize + "px"
    residueSpan.style.display = "inline-block"
    residueSpan.rowPos = n
    residueSpan.stepPos = n / opts.stepSize

    residueGroup.appendChild residueSpan
    n += opts.stepSize

  headerDiv.appendChild residueGroup
  return headerDiv
