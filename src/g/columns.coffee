Model = require("backbone-thin").Model
_ = require "underscore"

# model for column properties (like their hidden state)
module.exports = Columns = Model.extend

  initialize: (o,stat) ->
    # hidden columns
    @.set "hidden", [] unless @.get("hidden")?
    @stats = stat

  # assumes hidden columns are sorted
  # @returns n [int] number of hidden columns until n
  calcHiddenColumns: (n) ->
    hidden = @get "hidden"
    newX = n
    for i in hidden
      if i <= newX
        newX++
    newX - n
