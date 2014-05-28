define [], () ->
  class Selection

    constructor: (@msa) ->


     # removes all existing selections
    _cleanupSelections: () ->
      @_removeHorizontalSelection()
      @_removeVerticalSelection()
      @_removePositionSelection()
