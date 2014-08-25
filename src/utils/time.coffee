module.exports =
  waitForPause: (ms, callback) ->
    clearTimeout @timer
    args = arguments
    @timer = setTimeout ->
      callback()
    , ms
