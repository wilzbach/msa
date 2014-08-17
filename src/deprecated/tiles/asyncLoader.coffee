module.exports =
class AsyncLoader

  constructor: (@tilestage) ->

  asyncLoader: (height,x,y,vx,vy) ->
    if height is @tilestage.msa.zoomer.columnHeight
      if x < @tilestage.maxWidth / @tilestage.tileSize and y < @tilestage.maxHeight / @tilestage.tileSize and x >= 0 and y >= 0
        unless @tilestage.map[height]?[x]?[y]?
          # prerender the cached sequence on stage
          console.log "prerender:" + x + ",j:" + y
          @tilestage.seqtile.drawTile x,y

        # draw left triangular
        setTimeout (=> @asyncLoader height,x + vx,y + vy,vx,vy),100
