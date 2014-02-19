###
Grid: for entities that might want to snap to a grid.
###
Crafty.c "Grid",
  init: ->
    @attr
      w: Game.map_grid.tile.width
      h: Game.map_grid.tile.height

    return

  at: (x, y) ->
    if x is `undefined` and y is `undefined`
      x: @x / Game.map_grid.tile.width
      y: @y / Game.map_grid.tile.height
    else
      @attr
        x: x * Game.map_grid.tile.width
        y: y * Game.map_grid.tile.height

      this

###
Actor: shorthand for 2D entities using a grid.
###
Crafty.c "Actor",
  init: ->
    @requires "2D, Canvas, Grid"
    return


###
Train: moves along track, contains movement logic.
###
Crafty.c "Train",
  init: ->
    @requires "Actor, Keyboard"
    @speed = Constants.FULL_SPEED
    @playerOne = false
    @angle = 0
    @userCurve = false
    @isCurving = false
    @progress = 0
    return

  checkCollision: ->
    # Not using Crafty's collision detection because bounding circles are what's needed
    # Inefficient (compares every combination twice), but everything is fast for small n
    other = this
    collisionFound = false
    Crafty("Train").each ->
      collisionFound = true  if Math.sqrt(((other.x - @x) * (other.x - @x))) + Math.sqrt(((other.y - @y) * (other.y - @y))) < 22  unless @playerOne is other.playerOne
      return
    collisionFound

  findTrack: ->
    currentTrack = Util.trackAt(@at().x, @at().y)
    @currentTrack = currentTrack
    @angle = Util.endAngle(currentTrack.dir[1])
    this

  _finishSection: (dir) ->
    @angle = Util.endAngle(dir)
    @x = @currentTrack.x + Util.dirx(dir) * 14
    @y = @currentTrack.y + Util.diry(dir) * 14
    @lastDir = @nextDir
    @_updateCurrentTrack dir
    return

  _hasStraightOption: ->
    @currentTrack.dir.indexOf(@lastDir) > -1

  _hasCurveOption: ->
    @currentTrack.dir.length is 3 and (@currentTrack.dir.indexOf(Util.opposite(@lastDir)) > 0) or @currentTrack.dir.length is 2 and @currentTrack.dir.indexOf(@lastDir) is -1

  _moveAlongTrack: (dist) ->
    @remainingDist = dist
    remainingTries = 5
    @_removeSpriteComponent()
    @_addSpriteComponent()
    while @remainingDist > 0 and remainingTries-- > 0
      if @isCurving
        @_moveCurved()
      else
        @_moveStraight()
    if @lightLayer
      @lightLayer.attr
        x: @x
        y: @y

    return

  _moveStraight: ->
    @curveTo = null
    
    # Straight
    @progress = Util.dirx(@lastDir) * (@x - @currentTrack.x) + Util.diry(@lastDir) * (@y - @currentTrack.y)
    if @progress < Constants.TILE_HALF - @remainingDist
      
      # Move full distance
      @move @lastDir, @remainingDist
      @remainingDist = 0
    else
      
      # Snap and recalc
      @_finishSection @lastDir
      @remainingDist -= (Constants.TILE_HALF - @progress)
      @progress = 0
    return

  _moveCurved: ->
    # Curved
    @curveTo = Util.getTargetDirection(@currentTrack, @lastDir)
    angularDiff = 1 / 28 * @remainingDist * ((if ([
      "en"
      "nw"
      "ws"
      "se"
    ].indexOf(@lastDir + @curveTo) > -1) then -1 else 1))
    if @progress < Constants.CURVE_QUARTER - @remainingDist
      
      # Move full distance
      @angle += angularDiff
      @x += Math.cos(@angle) * @remainingDist
      @y += Math.sin(@angle) * @remainingDist
      @progress += @remainingDist
      @angle += angularDiff
      @remainingDist = 0
    else
      
      # Snap and recalc
      @_finishSection @curveTo
      @remainingDist -= (Constants.CURVE_QUARTER - @progress)
      @progress = 0
    @nextDir = @curveTo
    return


###
PlayerTrain: a train controlled by a player.
###
Crafty.c "PlayerTrain",
  init: ->
    @requires "Train"
    @passengers = 0
    @delivered = 0
    @followers = [] # following train cars
    @lightLayer = Crafty.e("2D, Canvas, LightLayer").attr(z: 11)
    @_beginMovement
    return
    
  _beginMovement: () ->
    @bind "EnterFrame", ->
      nextDirection = Util.getTargetDirection(@currentTrack, @lastDir)
      if nextDirection is "s"
        @attr "z", 3
        @followers[0].attr "z", 2
        @followers[1].attr "z", 1
      else if nextDirection is "n"
        @attr "z", 1
        @followers[0].attr "z", 2
        @followers[1].attr "z", 3
      return

  _addSpriteComponent: (dir) ->
    @addComponent "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if @curveTo and @progress > 28 * Math.PI / 8 then @curveTo else @lastDir))
    @lightLayer.addComponent "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if @curveTo and @progress > 28 * Math.PI / 8 then @curveTo else @lastDir)) + "light"
    return

  _removeSpriteComponent: ->
    baseSpriteName = "spr_" + ((if @playerOne then "r" else "b")) + "train"
    for i of Constants.DIR_PREFIXES
      @removeComponent baseSpriteName + Constants.DIR_PREFIXES[i], false
      @lightLayer.removeComponent baseSpriteName + Constants.DIR_PREFIXES[i] + "light", false
    return

  _setBraking: (braking) ->
    if braking
      unless @arrow
        @arrow = Crafty.e("DirectionArrow").attr(
          x: @x
          y: @y - 30
        ).attr(target: this)
    else
      if @arrow
        @arrow.destroy()
        @arrow = null
    @userCurve = braking
    playerOne = @playerOne
    Crafty("Train").each ->
      @speed = ((if braking then Constants.REDUCED_SPEED else Constants.FULL_SPEED))  if @playerOne is playerOne
      return
    return

  bindKeyboardTurn: (keyCode) ->
    if keyCode?
      @bind "KeyDown", do (e=keyCode) ->
        (e) ->
          @_setBraking true  if e.keyCode is keyCode
      @bind "KeyUp", do (e=keyCode) ->
        (e) ->
          @_setBraking false  if e.keyCode is keyCode
      this
    else
      @bind "EnterFrame", ->
        if @speed is Constants.REDUCED_SPEED
          @_setBraking false  if Math.random() > 0.925
        else
          @_setBraking true  if Math.random() > 0.94
        return

  _arriveAtStation: ->
    if @currentTrack.station
      station = @currentTrack.station
      @_dropoff station
      passengersGained = @_pickup station
      @_assignDestinations passengersGained, station, @playerOne
      @_updateStationSprites()
    return

  _dropoff: (station) ->
    deliveries = ((if @playerOne then station.dropoffP1 else station.dropoffP2))
    @passengers -= deliveries
    @delivered += deliveries
    (if @playerOne then station.dropoffP1 = 0 else station.dropoffP2 = 0)
    return

  _pickup: (station) ->
    room = 100 - @passengers
    overflow = station.population - room # number that will be left waiting
    pickup = ((if overflow > 0 then 100 - @passengers else station.population))
    station.population = ((if overflow > 0 then overflow else 0))
    @passengers += pickup
    return pickup

  _assignDestinations: (passengers, boardedAtStation, onPlayerOne) ->
    targetCount = Crafty("Station").length
    while passengers > 0
      target = Crafty(Crafty("Station")[Math.floor(Math.random() * targetCount)])
      unless target is boardedAtStation
        (if onPlayerOne then target.dropoffP1++ else target.dropoffP2++)
        passengers--
    return
    
  _updateStationSprites: () ->
    Crafty("Station").each ->
      @updateSprites()
    Crafty("PlayerScore").each ->
      @update()
    
  _updateCurrentTrack: (dir) ->
    @currentTrack = Util.trackAt(@currentTrack.at().x + Util.dirx(dir), @currentTrack.at().y + Util.diry(dir))
    @_arriveAtStation()
    straight = @_hasStraightOption()
    curve = @_hasCurveOption()
    @isCurving = ((if straight and curve then @userCurve else curve))
    if straight and curve
      @followers[0].curves.push @isCurving
      @followers[1].curves.push @isCurving
    return

Crafty.c "FollowTrain",
  init: ->
    @requires "Actor, Train"
    @curves = []
    @lightLayer = Crafty.e("2D, Canvas, LightLayer").attr(z: 11)
    return

  _addSpriteComponent: ->
    dir = ((if @curveTo and @progress > 28 * Math.PI / 8 then @curveTo else @lastDir))
    spriteName = "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if dir is "n" or dir is "s" then "side" else ""))
    @addComponent spriteName
    @lightLayer.addComponent spriteName + "light"
    return

  _removeSpriteComponent: ->
    baseSpriteName = "spr_" + ((if @playerOne then "r" else "b")) + "train"
    @removeComponent(baseSpriteName, false).removeComponent baseSpriteName + "side", false
    @lightLayer.removeComponent(baseSpriteName + "light", false).removeComponent baseSpriteName + "sidelight", false
    return

  _updateCurrentTrack: (dir) ->
    @currentTrack = Util.trackAt(@currentTrack.at().x + Util.dirx(dir), @currentTrack.at().y + Util.diry(dir))
    @isCurving = ((if @_hasCurveOption() and @_hasStraightOption() then (@curves.shift() or false) else @_hasCurveOption()))
    return


###
Track section: a 1x1 piece of track with two or more dirs.
###
Crafty.c "TrackSection",
  init: ->
    @requires "Actor"
    return
    
  associateStation: (station) ->
    @station = station
    return


###
Station: associated with a track, has passenger values.
###
Crafty.c "Station",
  init: ->
    @population = 0
    @dropoffP1 = 0
    @dropoffP2 = 0
    @popular = false
    @requires "Actor"
    @bind "EnterFrame", ->
      @populate()  if GameState.running
      return
    return

  setPopular: (popular) ->
    letter = @letter
    @popular = not @popular
    popular = @popular
    Crafty("spr_" + ((if @popular then "" else "p")) + "stop" + @letter).each ->
      @removeComponent "spr_" + ((if popular then "" else "p")) + "stop" + letter, false
      @addComponent "spr_" + ((if popular then "p" else "")) + "stop" + letter
      return
    return

  setup: (x, y, dir) ->
    @at x, y
    @setupAttach dir
    return

  setupAttach: (dir) ->
    x = @at().x
    y = @at().y
    @facing = dir
    if dir is "s"
      @attachToTrack(x, y + 1).attachToTrack x + 1, y + 1
    else
      @attachToTrack(x + Util.dirx(dir), y).attachToTrack x + Util.dirx(dir), y + 1
    @setupText()
    return

  setupText: ->
    @t = []
    @previousWaiting = 0
    @updateSprites()
    return

  populate: ->
    @numStations = Crafty("Station").length  unless @numStations
    if Math.random() > (((if @popular then 0.917 else 0.947)) + 0.005 * @numStations)
      @population += 1
      @updateSprites()
    return

  attachToTrack: (x, y) ->
    Util.trackAt(x, y).associateStation this
    this

  updateSprites: ->
    if @population / 12.0 is @t.length + 1
      remaining = Math.min(@population, 72) - (@t.length) * 12
      pos = @t.length
      if @facing is "w"
        x = @_x + 6 * (pos % 2)
        y = @_y + 2 + 8 * pos
      else if @facing is "e"
        x = @_x + 20 - 6 * (pos % 2)
        y = @_y + 2 + 8 * pos
      else
        x = @_x + 2 + 8 * pos
        y = @_y + 12 + 4 * (pos % 2)
      while remaining >= 12
        @t.push Crafty.e("StationPerson").attr(
          x: x
          y: y
        ).fadeIn(@facing)
        remaining -= 12
        pos++
    else
      while @t.length > @population / 12
        @t[@t.length - 1].fadeOut()
        @t.splice @t.length - 1, 1
    this


###
###
Crafty.c "StationPerson",
  init: ->
    @requires "2D, Canvas, spr_person00"
    return

  fadeIn: (dir) ->
    @alpha = 0
    @x -= Util.dirx(dir) * 10
    @y -= Util.diry(dir) * 10
    i = 0

    while i <= 9
      setTimeout do (o=this, dir=dir) ->
          -> 
              o.attr
                alpha: o.alpha + 0.1
                x: o.x + Util.dirx(dir)
                y: o.y + Util.diry(dir)
              return
      , i * 50
      i++
    this

  fadeOut: ->
    delay = Math.random() * 300
    i = 0

    while i <= 9
      setTimeout do (o=this) ->
        ->
          o.attr
            alpha: o.alpha - 0.1
            y: o._y - 3 * (o.alpha - 0.6)

          o.destroy()  if o.alpha < 0.1
          return
      , (i * 50 + delay)
      i++
    this

Crafty.c "PlayerScore",
  init: ->
    @requires("2D, DOM, Text").textFont
      size: "20px"
      family: "Aller"

    @display = 0
    @attr
      h: 47
      w: 270

    @css
      padding: 5
      backgroundColor: "none"
      margin: 10

    @bind "EnterFrame", ->
      (if @display > @train.passengers then @display-- else @display++)  unless @display is @train.passengers
      @text @display + "% Full"
      return

    return

  setup: ->
    @bar = Crafty.e("BarController").attr(
      x: @x + 10
      y: @y
    ).attr(playerOne: @playerOne).setup().update()
    @attr z: 0
    return

  update: ->
    if @train
      x = []
      p = @playerOne
      Crafty("Station").each ->
        t = ((if p then @dropoffP1 else @dropoffP2))
        if t > 1
          x.push [
            t
            this.letter
            this.popular
          ]
        return

      x.sort (a, b) ->
        b[0] - a[0]

      @bar.update @train.passengers, x
    return

Crafty.c "DirectionArrow",
  init: ->
    @requires("Actor, spr_arrowsign").attr(z: 1000).bind "EnterFrame", ->
      if GameState.running
        @x = @target.x
        @y = @target.y - 30
      return

    return

Crafty.c "Dialog",
  init: ->
    @requires("2D, DOM, Text").css(
      backgroundColor: "#2B281D"
      textAlign: "center"
      border: "4px solid #FFFDE8"
    ).textFont(
      size: "30px"
      family: "Aller"
    ).textColor "#FFFDE8"
    @attr
      x: 0
      y: 112
      w: 268
      h: 130

    return

Crafty.c "ClockController",
  init: ->
    @pauseAvailable = true
    @paused = false
    @requires("Dialog").attr(
      x: 234
      y: 492
      w: 140
      h: 44
    ).textColor("#84FFEC").textFont(
      size: "43px"
      family: "Minisystem"
    ).css (
      letterSpacing: "-2px"
      border: "4px solid #606060"
      textShadow: "0px 0px 2px #84FFEC"
    )
    GameClock.newDay()
    @text GameClock.hour + ((if GameClock.minute > 9 then ":" else ":0")) + GameClock.minute
    @tickDelay = 0
    @bind "EnterFrame", ->
      percentTimePassed = (GameClock.hour - 6) / 4 + (GameClock.minute / 240)
      if GameState.running and @tickDelay++ > 22
        GameClock.update()
        @text GameClock.hour + ((if GameClock.minute > 9 then ":" else ":0")) + +GameClock.minute
        @tickDelay = 0
        Util.gameOver false  if GameClock.hour is 10
      Crafty("AmbientLayer").each ->
        @color Util.sunrise(percentTimePassed)
        return

      Crafty("LightLayer").each ->
        @attr "alpha", 1 - percentTimePassed
        return

      return

    setTimeout (->
      GameState.running = true
      return
    ), 1000
    @bind "KeyDown", (e) ->
      if e.keyCode is Crafty.keys.SPACE
        if @pauseAvailable
          Crafty.e "PauseText"
          @pauseAvailable = false
          GameState.running = false
          @paused = true
        else if @paused
          Crafty("PauseText").teardown()
          Crafty("PauseText").destroy()
          GameState.running = true
          @paused = false
      return

    return


###
Controls train movement. Makes sure all trains move before checking collision.
###
Crafty.c "TrainController",
  init: ->
    @bind "EnterFrame", ->
      if GameState.running
        Crafty("Train").each ->
          @_moveAlongTrack @speed
          return

        Crafty("Train").each ->
          Util.gameOver true  if @checkCollision()
          return

      return

    return

Crafty.c "EndingText",
  init: ->
    @requires("Dialog").textFont size: "20px"
    @display = 0
    @attr
      x: 0
      y: 112
      w: 268
      h: 130

    @css
      padding: 20
      margin: "0px 150px"
      width: 600
      height: 200
      boxShadow: "-8px 8px 0px rgba(0,0,0,0.4)"

    @bind "KeyDown", (e) ->
      if e.keyCode is Crafty.keys.SPACE
        Crafty("TrainController").destroy() # Because of the 2D issue
        Crafty.scene "PlayGame"
      return

    Crafty.e("2D, DOM, spr_space").attr
      x: @x + 260
      y: @y + 152

    return

Crafty.c "PauseText",
  init: ->
    @requires "Dialog"
    @text "<br/><br/>Only once a shift!"
    @css
      padding: 20
      margin: "0px 150px"
      width: 600
      height: 200
      boxShadow: "-8px 8px 0px rgba(0,0,0,0.4)"

    @coffee = Crafty.e("2D, DOM, spr_coffee").attr(
      x: @x + 240
      y: @y + 20
    )
    @space = Crafty.e("2D, DOM, spr_space").attr(
      x: @x + 260
      y: @y + 152
    )
    return

  teardown: ->
    @coffee.destroy()
    @space.destroy()
    return

Crafty.c "VictoryText",
  init: ->
    @requires "EndingText"
    p1score = 0
    p2score = 0
    Crafty("PlayerTrain").each ->
      if @playerOne
        p1score = @delivered
      else
        p2score = @delivered
      return

    unless p1score is p2score
      @css
        border: "4px solid #" + ((if p1score > p2score then "E23228" else "4956FF"))
        borderTop: "4px solid #" + ((if p1score > p2score then "FF817C" else "848EFF"))
        borderBottom: "4px solid #" + ((if p1score > p2score then "B71607" else "1E2DCE"))

    @text "The morning rush is over!<br/>Passengers delivered:<br/>Red: " + p1score + ", Blue: " + p2score + "<br/>" + ((if p1score is p2score then "It's a Draw!" else (((if p1score > p2score then "Red" else "Blue")) + " Line wins!"))) + "<br/>Total deliveries: " + (p1score + p2score)
    return

Crafty.c "FailureText",
  init: ->
    @requires "EndingText"
    @text Constants.ENDING_DIALOGS[0][Math.floor(Math.random() * Constants.ENDING_DIALOGS[0].length)] + "<br/>" + Constants.ENDING_DIALOGS[1][Math.floor(Math.random() * Constants.ENDING_DIALOGS[1].length)]
    return

Crafty.c "BarController",
  init: ->
    @requires("2D, Canvas").attr z: 15
    return

  setup: ->
    @attr
      h: 20
      w: 20

    c = ((if @playerOne then "r" else "b"))
    Crafty.e("2D, Canvas, spr_barback").attr
      x: @x
      y: @y
      z: 15

    @l = Crafty.e("2D, Canvas, spr_" + c + "barl").attr(
      x: @x
      y: @y
      z: 15
    )
    @b = Crafty.e("2D, Canvas, spr_" + c + "bar").attr(
      w: 0
      x: @x + 4
      y: @y
      z: 15
    )
    @r = Crafty.e("2D, Canvas, spr_" + c + "barr").attr(
      x: @x + 4
      y: @y
      z: 15
    )
    this

  update: (fullness, ticks) ->
    @attr
      x: @x
      y: @y
      z: 15
    @l.attr
      x: @x
      y: @y
      z: 15
    @b.attr
      x: @x + 4
      w: ((if fullness > 4 then fullness * 2 - 8 else 0))
      z: 15
    @r.attr
      x: ((if fullness > 2 and ticks.length then @x - 4 + fullness * 2 else @x + 4))
      z: 15
    for i of @ticks
      @ticks[i].destroy()
    @ticks = []
    for i of @stops
      @stops[i].destroy()
    @stops = []
    d = -2
    previous = 0
    for i of ticks
      if ticks[i][0] > 0
        attempt = @x + d + ((ticks[i][0] | 1) - 1) - 6
        attempt += 2  while i > 0 and attempt < previous + 12
        @stops.push Crafty.e("2D, Canvas, spr_" + ((if ticks[i][2] then "p" else "")) + "stop" + ticks[i][1]).attr(
          x: attempt
          y: @y - 22
          z: 15
        )
        previous = attempt
      if i < ticks.length - 1
        d += ticks[i][0] * 2
        @ticks.push Crafty.e("2D, Canvas, spr_" + ((if @playerOne then "r" else "b")) + "bart").attr(
          x: @x + d
          y: @y
          z: 15
        )
    this


###
A line of text to simplify the title screen.
###
Crafty.c "TitleText",
  init: ->
    @requires("2D, DOM, Text").attr(
      x: 0
      w: 616
    ).css(textAlign: "center").textFont(
      size: "17px"
      family: "Aller"
    ).textColor "#FFFDE8"
    return
