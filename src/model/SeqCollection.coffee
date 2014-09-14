Sequence = require "./Sequence"
Collection = require("backbone").Collection

module.exports = SeqManager = Collection.extend
  model: Sequence

  constructor: ->

    Collection.apply @, arguments

    # invalidate cache
    @on "all", ->
      @lengthCache = null
    , @
    @lengthCache = null

    @

  # gives the max length of all sequences
  # (cached)
  getMaxLength: () ->
    return 0 if @models.length is 0
    if @lengthCache is null
      @lengthCache = @max((seq) -> seq.get("seq").length).get("seq").length
    return @lengthCache

  # gets the previous model
  # @param endless [boolean] for the first element
  # true: returns the last element, false: returns undefined
  prev: (model, endless) ->
    index = @indexOf(model) - 1
    index = @.length - 1 if index < 0 and endless
    @at(index)

  # gets the next model
  # @param endless [boolean] for the last element
  # true: returns the first element, false: returns undefined
  next: (model, endless) ->
    index = @indexOf(model) + 1
    index = 0 if index == @.length and endless
    @at(index)

  # @returns n [int] number of hidden columns until n
  calcHiddenSeqs: (n) ->
    nNew = n
    for i in [0..nNew]
      if @at(i).get("hidden")
        nNew++
    nNew - n

