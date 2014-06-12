define ["cs!msa/selection/selectionlist"],(SelectionList) ->
  class SelectionManager

    constructor: (@msa, @eventhandler) ->

    changeSel: (sel) ->
      # remove old
      @currentSelection.deselect() if @currentSelection?

      # apply now
      @currentSelection = sel
      sel.select() if sel?

      # broadcast to event handler
      @eventhandler.onSelectionChanged(sel)

    # detects shiftKey
    handleSel: (sel, evt) ->
      if evt.ctrlKey or evt.metaKey
        # check whether we already have a list
        if @currentSelection?.isList?
          selList = @currentSelection
          @currentSelection = undefined
        else
          # create new list
          selList = new SelectionList()

        # add
        selList.addSelection sel
        sel = selList

      @changeSel sel

    cleanup: ->
      @changeSel(undefined)

