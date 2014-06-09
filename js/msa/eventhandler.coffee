define [], ->
  class EventHandler
    constructor: (@log) ->
      @subscribers = []

    notifyNewItemReleased: (item) ->
      subscriber.callback(item) for subscriber in @subscribers when subscriber.item is item

    subscribe: (to, onNewItemReleased) ->
      @subscribers.push {'item': to, 'callback': onNewItemReleased}

    # TODO: apply observer pattern and deprecate all callbacks

    onColumnSelect: (pos) ->
      @log "column was clicked at #{pos}"

    onRowSelect: (id) ->
      @log "row was clicked at #{id}"

    onPositionClicked: (id, pos) =>
      @log "seq #{id} was clicked at #{pos}"

    onAnnotationClicked: ->
      @log "not implemented yet"

    onRegionSelected: ->
      @log "not implemented yet"

    onZoom: ->
      @log "not implemented yet"

    onScroll: ->
      @log "not implemented yet"

    onColorSchemeChanged: ->
      @log "not implemented yet"

    onDisplayEventChanged: ->
      @log "not implemented yet"
