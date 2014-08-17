Model = require("backbone").Model
module.exports = Zoomer = Model.extend

  defaults:
    columnWidth: 16
    rowHeight: 10
    textVisible: true
    labelLength: 20
    labelFontsize: "10px"
    labelOffset: 100
    stepSize: 2
