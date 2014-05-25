define [], () ->
  class HttpRequest

    @fetch:(url, callback)->
      req = @getXMLRequest()
      req.addEventListener 'readystatechange', =>
        if req.readyState is 4
          successResultCodes = [200, 304]
          if req.status in successResultCodes
            text = req.responseText
            callback(text)
          else
            console.log 'Error loading data...'

      # prevent xml parsing by Firefox
      req.overrideMimeType 'text/plain'
      req.open "GET", url,true
      req.send()

    # support for IE
    @getXMLRequest: () ->
      if XMLHttpRequest?
        return new XMLHttpRequest()
      else
        console.log 'XMLHttpRequest is undefined'
        @XMLHttpRequest = ->
          try
            return new ActiveXObject("Msxml2.XMLHTTP.6.0")
          catch error
          try
            return new ActiveXObject("Msxml2.XMLHTTP.3.0")
          catch error
          try
              return new ActiveXObject("Microsoft.XMLHTTP")
          catch error
          throw new Error("This browser does not support XMLHttpRequest.")
