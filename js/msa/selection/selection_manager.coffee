define [], ->
  class SelectionManager

    constructor: (@msa) ->

    changeSel: (sel) ->
      # remove old
      @currentSelection.deselect() if @currentSelection?

      # apply now
      @currentSelection = sel
      sel.select() if sel?

    cleanup: ->
      @changeSel(undefined)

