Model = require("backbone").Model

# model for column properties (like their hidden state)
module.exports = Columns = Model.extend

  initialize: ->
    # hidden columns
    @.set "hidden", []
