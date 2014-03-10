$(document).ready(() ->
  window.singlePlayerMode = false
  
  $(window).keydown((e) ->
    if (!(window.dontGoAway) && !($(e.target).is("textarea, a")))
      $('#display-manual').hide()
      $('#display-design').hide()
    window.dontGoAway = false
    true
  )
  $("body").click((e) ->
    if !($(e.target).is("textarea, a"))
      $('#display-manual').hide()
      $('#display-design').hide()
  )
  $('.linkbar a:nth-child(1)').click(() ->
    if $('#display-manual:visible').length
      $('#display-manual').hide()
    else
      $('#display-design').hide()
      $('#display-manual').show()
    false
  )
  $('.linkbar a:nth-child(2)').click(() ->
    if $('#display-design:visible').length
      $('#display-design').hide()
    else
      $('#display-manual').hide()
      $('#display-design').show()
    false
  )
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
