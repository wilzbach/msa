define(["cs!./vertical_selection", "cs!./horizontal_selection", "cs!./region_select",
    "cs!./position_selection", "cs!./selection_manager", "cs!./selectionlist"],
    function (VerticalSelection, HorizontalSelection, RegionSelect,
      PositionSelect, SelectionManager, SelectionList,
      Selection) {
    return {
        VerticalSelection: VerticalSelection,
        HorizontalSelection: HorizontalSelection,
        RegionSelect: RegionSelect,

        PositionSelect: PositionSelect,
        SelectionManager: SelectionManager,
        SelectionList: SelectionList,
    }
});

