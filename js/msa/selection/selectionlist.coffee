define [], ->
  class SelectionList

    constructor: ->
      @_sels = []

    addSelection: (sel) ->
      eId = sel.getId()
      if eId of @_self
        console.log "duplicate selection"
      else
        @_sels[eId] = sel
        sel.select


    desselect: ->
      for key, value of @_self
        value.disselect()
