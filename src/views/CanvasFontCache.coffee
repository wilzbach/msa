Events = require("biojs-events")

module.exports = class CanvasFontCache

  constructor: ->
    #Events.mixin @::
    @cache = {}
    @cacheHeight = 0
    @cacheWidth = 0

  getFontTile: (letter, width, height) ->
    # validate cache
    if width isnt @cacheWidth or height isnt @cacheHeight
      @cacheHeight = height
      @cacheWidth = width
      @cache = {}

    if @cache[letter] is undefined
      @createTile letter, width, height

    return @cache[letter]

  createTile: (letter, width, height) ->

    canvas = @cache[letter] = document.createElement "canvas"
    canvas.width = width
    canvas.height = height
    @ctx = canvas.getContext '2d'
    @ctx.font = "13px mono"
    @ctx.textBaseline = 'middle'
    @ctx.textAlign = "center"

    #@ctx.strokeStyle = "#333"
    @ctx.fillText letter,width / 2,height / 2,width
    # save
    #@cache[letter] = @ctx.getImageData 0,0,width,height

    #@ctx.clearRect 0,0,width, height
