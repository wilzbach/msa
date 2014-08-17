view = require("./views/view")
$ = require "jbone"

RegionSelect = view.extend
  tagName: "canvas"
  initialize: ->
    @el.style.width = "1000px"
    @el.style.height = "500px"
    @el.style.position = "absolute"
    @el.style.top = 0
    @ctx = @el.getContext('2d')
    @ctx.globalAlpha = 0.5

  events:
    mousedown: "mousedown"
    mouseup: "mouseup"
    mousemove: "mousemove"

  mousedown: (e) ->
    @start = [e.pageX, e.pageY]
    console.log @start
    e.preventDefault()

  mousemove: (e) ->
    return unless @start?

    @ctx.clearRect(0, 0, @el.width, @el.height)

    x = e.pageX
    y = e.pageY

    #@ctx.rect(@start[0], @start[1], x - @start[0], y - @start[1])
    @ctx.fillRect(@start[0], @start[1], 100 + @start[0], 100 + @start[1])
    #@ctx.fillRect(0,0,100,100)
    e.preventDefault()

  mouseup: (e) ->
    end = [e.pageX, e.pageY]
    x1 = Math.min(@start[0], end[0])
    x2 = Math.max(@start[0], end[0])
    y1 = Math.min(@start[1], end[1])
    y2 = Math.max(@start[1], end[1])
    obj = {x1:x1,y1:y1,x2:x2,y2:y2}
    console.log obj
    # clear
    @start = undefined
    @ctx.clearRect(0, 0, @el.width, @el.height)
    e.preventDefault()

module.exports = RegionSelect
