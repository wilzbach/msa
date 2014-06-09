define [], ->
  class SelectionList

    isList: true

    constructor: ->
      @_sels = []

    addSelection: (sel) ->
      eId = sel.getId()
      if @_sels[eId]?
        console.log "duplicate selection"
      else
        @_sels[eId] = sel
        sel.select()

    select: ->
      undefined

    deselect: ->
      for key, value of @_sels
        value.deselect()
