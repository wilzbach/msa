define [], () ->
  class GenericReader
    constructor: (@url) ->

    _fetch: ->
      xmlHttp = null;
      xmlHttp = new XMLHttpRequest();
      xmlHttp.open( "GET", @url, false );
      xmlHttp.send( null );
      return xmlHttp.responseText;

  return GenericReader
