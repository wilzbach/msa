define ["cs!input/http_request"], (HttpRequest) ->
  class GenericReader

    constructor: (@text) ->

    toString:() ->
      return @text

    @read: (url, callback) ->
      onret = (text) => @_onRetrieval(text,callback)
      HttpRequest.fetch(url, onret, callback)

    @_onRetrieval:(text, callback) ->
      return callback(new @(text))
