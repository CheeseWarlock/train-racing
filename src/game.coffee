$(document).ready(() ->
  window.singlePlayerMode = false
  window.Brakes = true
  window.SwapColours = true
  window.StationStop = true
)

window.Game =
  map_grid:
    width: 22
    height: 20
    tile:
      width: 28
      height: 28
  width:
    () -> this.map_grid.width * this.map_grid.tile.width 
  height:
    () -> this.map_grid.height * this.map_grid.tile.height
  
  start: -> 
    window.HEADLESS_MODE = false
    Crafty.init(Game.width(), Game.height(), "game-stage")
    Crafty.pixelart(true)
    Crafty.background('#2B281D')
    Crafty.scene('Loading')
    this
    
  startHeadless: ->
    window.HEADLESS_MODE = true
    Crafty.init(Game.width(), Game.height(), "game-stage")
    Crafty.background('#2B281D')
    $.getJSON("map1.json", (data) ->
      window.selectedMap = data
      Crafty.scene('PlayGame')
    )
    this
