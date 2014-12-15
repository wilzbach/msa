Sequence = require "./Sequence"
FeatureCol = require "./FeatureCol"
Collection = require("backbone-thin").Collection

module.exports = SeqManager = Collection.extend
  model: Sequence

  constructor: ->
    Collection.apply @, arguments

    @on "add reset remove", =>
      # invalidate cache
      @lengthCache = null
      @_bindSeqsWithFeatures()
    , @
    @lengthCache = null

    @features = {}
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

  # you can add features independent to the current seqs as they may be added
  # later (lagging connection)
  addFeatures: (features) ->
    if features.config?
      obj = features
      features = features.seqs
      if obj.config.colors?
        colors = obj.config.colors
        _.each features, (seq) ->
          _.each seq, (val) ->
            if colors[val.feature]?
              val.fillColor = colors[val.feature]
    if _.isEmpty @features
      @features = features
    else
      _.each features, (val, key) =>
        unless key in @features
          @features[key] = val
        else
          @features[key] = _.union @features[key], val
    # rehash
    @_bindSeqsWithFeatures()

  # adds features to a sequence
  _bindSeqWithFeatures: (seq) ->
    # TODO: probably we don't always want to bind to name
    features = @features[seq.attributes.name]
    if features
      seq.set "features", new FeatureCol features
      seq.attributes.features.assignRows()
      seq.set "height", seq.attributes.features.getCurrentHeight() + 1

  # rehash the sequence feature binding
  _bindSeqsWithFeatures: () ->
    @each (seq) =>  @_bindSeqWithFeatures(seq)

  # removes all features from the cache (not from the seqs)
  removeAllFeatures: ->
    delete @features
