define(["cs!./vertical_selection", "cs!./horizontal_selection.coffee"], function (HorizontalSelection, VerticalSelection) {
    return {
        version: "0.1",
        verticial_selection: VerticalSelection,
        horizontal_selection: HorizontalSelection,
    }
});

