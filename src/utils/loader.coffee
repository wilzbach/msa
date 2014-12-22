k = require "koala-js"

module.exports = loader =

  # asynchronously require a script
  loadScript: (url, cb) ->
    s = k.mk "script"
    s.type = "text/javascript"
    s.src = url
    s.async = true
    s.onload = s.onreadystatechange = ->
      if not r and (not @readyState or @readyState is "complete")
        r = true
        cb()
    t = document.getElementsByTagName("script")[0]
    t.parentNode.appendChild s

  # joins multiple callbacks into one callback
  # a bit like Promise.all - but for callbacks
  joinCb: (retCb, finalLength, finalScope) ->
    finalLength = finalLength || 1
    cbsFinished = 0

    callbackWrapper = (cb, scope) ->
      if not cb?
        # directly called (without cb)
        counter()
      else
        ->
          if "apply" in cb
            cb.apply scope, arguments
          counter()

    counter = ->
      cbsFinished++
      if cbsFinished is finalLength
        retCb.call finalScope

    return callbackWrapper
