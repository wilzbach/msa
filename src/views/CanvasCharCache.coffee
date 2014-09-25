Events = require("biojs-events")

module.exports = class CanvasCharCache

  constructor: (@g) ->
    @cache = {}
    @cacheHeight = 0
    @cacheWidth = 0

  # returns a cached canvas
  getFontTile: (letter, width, height) ->
    # validate cache
    if width isnt @cacheWidth or height isnt @cacheHeight
      @cacheHeight = height
      @cacheWidth = width
      @cache = {}

    if @cache[letter] is undefined
      @createTile letter, width, height

    return @cache[letter]

  # creates a canvas with a single letter
  # (for the fast font cache)
  createTile: (letter, width, height) ->

    canvas = @cache[letter] = document.createElement "canvas"
    canvas.width = width
    canvas.height = height
    @ctx = canvas.getContext '2d'
    @ctx.font = @g.zoomer.get "residueFont"
    @ctx.textBaseline = 'middle'
    @ctx.textAlign = "center"

    @ctx.fillText letter,width / 2,height / 2,width
