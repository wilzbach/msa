define [], () ->
  class GenericReader
   fetch:(url, callback)->
      req = new XMLHttpRequest()
      req.addEventListener 'readystatechange', ->
        if req.readyState is 4 and req.status is 200
          @text = req.responseText
      req.open "GET", url,true
      req.send
