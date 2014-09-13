Events = require("biojs-events")

module.exports = class CanvasFontCache

  constructor: ->
    #Events.mixin @::
    @cache = {}
    @cacheHeight = 0
    @cacheWidth = 0

  getFontTile: (data) ->
    letter = data.letter
    # validate cache
    if data.width isnt @cacheWidth or data.height isnt @cacheHeight
      @cacheHeight = data.height
      @cacheWidth = data.width
      @cache = {}

    if @cache[letter] is undefined
      @createTile data

    return @cache[letter]

  createTile: (data) ->
    letter = data.letter
    width = data.width
    height = data.height

    canvas = @cache[letter] = document.createElement "canvas"
    canvas.width = width
    canvas.height = height
    @ctx = canvas.getContext '2d'
    @ctx.font="13px Droid Sans Mono"
    @ctx.textBaseline = 'middle'
    @ctx.textAlign="center"

    #@ctx.strokeStyle = "#333"
    @ctx.strokeText letter,width / 2,height / 2,width
    # save
    #@cache[letter] = @ctx.getImageData 0,0,width,height

    #@ctx.clearRect 0,0,width, height
