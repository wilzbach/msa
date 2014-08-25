# throttle time class with end trailing
# good explanation of the difference between throttling and bouncing
# http://drupalmotion.com/article/debounce-and-throttle-visual-explanation
module.exports =

  # TODO: not used
  # will call the fn minimal every drawPeriod
  throttleTrail: (ms, callback, drawPeriod) ->
    clearTimeout @timer
    console.log new Date() - @lastDraw
    if (new Date() - @lastDraw) > drawPeriod
      console.log "redraw"
      callback()
      @lastDraw = new Date()
    else
      @timer = setTimeout =>
        console.log "redraw"
        callback()
        @lastDraw = new Date()
      , ms

  # clears always the previous timeout
  bounce: (ms, callback) ->
    clearTimeout @timer
    @timer = setTimeout =>
      console.log "redraw"
      callback()
    , ms
