define [], ->
  class EventHandler
    constructor: (@log) ->
      undefined

    onColumnSelect: (pos) ->
      @log "column was clicked at pos" + pos

    onRowSelect: (id) ->
      @log "row was clicked at id" + id

    onPositionClicked: (id, pos) ->
      @log "seq " + id +" was clicked at " + pos

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
