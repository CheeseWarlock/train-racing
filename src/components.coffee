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
    @requires (if window.HEADLESS_MODE then "2D, Grid" else "Actor, Keyboard")
    @speed = Constants.FULL_SPEED
    @playerOne = false
    @angle = 0
    @curveCommandEnabled = false
    @progress = 0
    @targetDirection
    @sourceDirection
    @distanceTraveled = 0
    return

  checkCollision: ->
    # Not using Crafty's collision detection because bounding circles are what's needed
    # Inefficient (compares every combination twice), but everything is fast for small n
    other = this
    collisionFound = false
    Crafty("Train").each ->
      collisionFound = true  if Math.sqrt(((other.x - @x) * (other.x - @x))) + Math.sqrt(((other.y - @y) * (other.y - @y))) < Constants.COLLISION_SIZE  unless @playerOne is other.playerOne
      return
    collisionFound

  findTrack: ->
    currentTrack = Util.trackAt(@at().x, @at().y)
    @currentTrack = currentTrack
    @angle = Util.endAngle(currentTrack.dir[1])
    this
    
  isCurving: ->
    @sourceDirection != @targetDirection

  _finishSection: (dir) ->
    if (@reversing)
      if (true and !(@_hasCurveOption() and @_hasStraightOption()) and @currentTrack.dir.length == 3)
        @curves.push @_hasCurveOption()
    @angle = Util.endAngle(dir)
    @x = @currentTrack.x + Util.dirx(dir) * Constants.TILE_HALF
    @y = @currentTrack.y + Util.diry(dir) * Constants.TILE_HALF
    @sourceDirection = @targetDirection
    @_updateCurrentTrack dir
    if @_arriveAtStation? then @_arriveAtStation()
    return

  _hasStraightOption: ->
    @currentTrack.dir.indexOf(@sourceDirection) > -1

  _hasCurveOption: ->
    @currentTrack.dir.length is 3 and (@currentTrack.dir.indexOf(Util.opposite(@sourceDirection)) > 0) or @currentTrack.dir.length is 2 and @currentTrack.dir.indexOf(@sourceDirection) is -1

  moveAlongTrack: (dist) ->
    @distanceTraveled += dist
    @reversing = (dist < 0)
    if (@reversing)
      @angle = @angle + Math.PI
      if (@isCurving())
        @progress = Constants.TILE_HALF * Math.PI / 2 - @progress
      else
        @progress = -@progress
      dist = -dist
      temp = @sourceDirection
      @sourceDirection = Util.opposite(@targetDirection)
      @targetDirection = Util.opposite(temp)
      
    @remainingDist = dist
    remainingTries = Constants.TILE_JUMP_LIMIT
    @_removeSpriteComponent()
    @_addSpriteComponent()
    while @remainingDist > 0 and remainingTries-- > 0
      if @isCurving()
        @_moveCurved()
      else
        @_moveStraight()
    if @lightLayer
      @lightLayer.attr
        x: @x
        y: @y
        
    if (@reversing)
      @angle = @angle - Math.PI
      temp = @sourceDirection
      @sourceDirection = Util.opposite(@targetDirection)
      @targetDirection = Util.opposite(temp)
      if (@isCurving())
        @progress = Constants.TILE_HALF * Math.PI / 2 - @progress
      else
        @progress = -@progress

    return

  _moveStraight: ->
    # Straight
    @progress = Util.dirx(@sourceDirection) * (@x - @currentTrack.x) + Util.diry(@sourceDirection) * (@y - @currentTrack.y)
    if @progress < Constants.TILE_HALF - @remainingDist
      
      # Move full distance
      @move @sourceDirection, @remainingDist
      @remainingDist = 0
    else
      
      # Snap and recalc
      @_finishSection @sourceDirection
      @remainingDist -= (Constants.TILE_HALF - @progress)
      @progress = 0
    return

  _moveCurved: ->
    # Curved
    counterClockwise = ((if (@sourceDirection + @targetDirection) in ["en","nw","ws","se"] then -1 else 1))
    angularDiff = 1 / (Constants.TILE_HALF * 2) * @remainingDist * counterClockwise
    if @progress < Constants.CURVE_QUARTER - @remainingDist
      
      # Move full distance
      @angle += angularDiff
      @x += Math.cos(@angle) * (Math.sin(angularDiff) * (Constants.TILE_HALF * 2)) * counterClockwise
      @y += Math.sin(@angle) * (Math.sin(angularDiff) * (Constants.TILE_HALF * 2)) * counterClockwise
      @progress += @remainingDist
      @angle += angularDiff
      @remainingDist = 0
    else
      
      # Snap and recalc
      @_finishSection @targetDirection
      @remainingDist -= (Constants.CURVE_QUARTER - @progress)
      @progress = 0
    return


###
TrainHead: the first car of a train. Master of the movement of its train.
###
Crafty.c "TrainHead",
  init: ->
    @requires "Train"
    @passengers = 0
    @delivered = 0
    @followers = [] # following train cars
    if (!window.HEADLESS_MODE)
      @lightLayer = Crafty.e("2D, Canvas, LightLayer").attr(z: 1000)
    return
    
  _addSpriteComponent: (dir) ->
    if (!window.HEADLESS_MODE)
      @addComponent "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if @isCurving() and @progress > Constants.TILE_HALF * Math.PI / 4 then @targetDirection else @sourceDirection))
      @lightLayer.addComponent "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if @isCurving() and @progress > Constants.TILE_HALF * Math.PI / 4 then @targetDirection else @sourceDirection)) + "light"
    return

  _removeSpriteComponent: ->
    if (!window.HEADLESS_MODE)
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
    @curveCommandEnabled = braking
    playerOne = @playerOne
    if window.Brakes
      Crafty("Train").each ->
        @speed = ((if braking then Constants.REDUCED_SPEED else Constants.FULL_SPEED))  if @playerOne is playerOne
        
  isBraking: () ->
    @speed == Constants.REDUCED_SPEED

  
###
CarryingTrain: a train that "carries" passengers. Data is still stored in the TrainHead.
###
Crafty.c "CarryingTrain",
  init: () ->
    @requires("Train")
    @trans = []
    @inStation = false
    
  _arriveAtStation: ->
    station = @currentTrack.station
    if @currentTrack.station
      if @inStation
        droppedOff = @_dropoff station
        passengersGained = @_pickup station
        @_assignDestinations passengersGained, station, @playerOne
        @_updateStationSprites()
        x = (droppedOff + passengersGained)
        
        if window.GameClock.hour
          @trans.push([(((window.GameClock.hour-6) * 60) + window.GameClock.minute), passengersGained, droppedOff])
        switch 
          when x > 40 then Crafty.audio.play("get3")
          when x > 20 then Crafty.audio.play("get2")
          when x > 2 then Crafty.audio.play("get1")
        if (window.StationStop) then @head.stayDelay = 60
        @inStation = false
      else
        @inStation = true
    else
      @inStation = false
    return

  _dropoff: (station) ->
    deliveries = ((if @playerOne then station.dropoffP1 else station.dropoffP2))
    @head.passengers -= deliveries
    @head.delivered += deliveries
    (if @playerOne then station.dropoffP1 = 0 else station.dropoffP2 = 0)
    return deliveries

  _pickup: (station) ->
    room = Constants.MAX_PASSENGERS - @head.passengers
    overflow = station.population - room # number that will be left waiting
    pickup = ((if overflow > 0 then Constants.MAX_PASSENGERS - @head.passengers else station.population))
    station.population = ((if overflow > 0 then overflow else 0))
    @head.passengers += pickup
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


###
PlayerTrain: a train controlled by a player.
###
Crafty.c "PlayerTrain",
  init: () ->
    @requires("TrainHead")
    
  _updateCurrentTrack: (dir) ->
    backThroughCurve = (@reversing and !(@_hasCurveOption() and @_hasStraightOption()) and @currentTrack.dir.length == 3)
    if backThroughCurve
      for f in @followers
        f.curves.shift()
    @currentTrack = Util.trackAt(@currentTrack.at().x + Util.dirx(dir), @currentTrack.at().y + Util.diry(dir))
    straight = @_hasStraightOption()
    curve = @_hasCurveOption()
    @targetDirection = ((if (straight and curve and @curveCommandEnabled) or (curve and !straight) then Util.getTargetDirection(@currentTrack, @sourceDirection) else @sourceDirection))
    if straight and curve
      window.blamePlayerOne = @playerOne
      isCurving = @isCurving()
      for f in @followers
        f.curves.push isCurving
    return
    
  bindKeyboardTurn: (keyCode) ->
    if keyCode?
      @bind "KeyDown", do (e=keyCode) ->
        (e) ->
          if e.keyCode is keyCode and GameState.running
            Crafty.audio.play('brakeson')
            @_setBraking true  
      @bind "KeyUp", do (e=keyCode) ->
        (e) ->
          if e.keyCode is keyCode and GameState.running
            Crafty.audio.play('brakesoff')
            @_setBraking false  
      this


###
FollowTrain: a train car that follows a TrainHead or another FollowTrain.
###
Crafty.c "FollowTrain",
  init: ->
    @requires "Train"
    @curves = []
    if (!window.HEADLESS_MODE)
      @lightLayer = Crafty.e("2D, Canvas, LightLayer").attr(z: 1000)
    return

  _addSpriteComponent: ->
    if (!window.HEADLESS_MODE)
      dir = ((if @isCurving() and @progress > Constants.TILE_HALF * Math.PI / 4 then @targetDirection else @sourceDirection))
      spriteName = "spr_" + ((if @playerOne then "r" else "b")) + "train" + ((if dir is "n" or dir is "s" then "side" else ""))
      @addComponent spriteName
      @lightLayer.addComponent spriteName + "light"
    return

  _removeSpriteComponent: ->
    if (!window.HEADLESS_MODE)
      baseSpriteName = "spr_" + ((if @playerOne then "r" else "b")) + "train"
      @removeComponent(baseSpriteName, false).removeComponent baseSpriteName + "side", false
      @lightLayer.removeComponent(baseSpriteName + "light", false).removeComponent baseSpriteName + "sidelight", false
    return

  _updateCurrentTrack: (dir) ->
    @currentTrack = Util.trackAt(@currentTrack.at().x + Util.dirx(dir), @currentTrack.at().y + Util.diry(dir))
    curve = @_hasCurveOption()
    straight = @_hasStraightOption()
    @targetDirection = ((if (curve and straight and (@curves.shift() or false)) or (curve and !straight) then Util.getTargetDirection(@currentTrack, @sourceDirection)  else @sourceDirection))
    return


###
AITrain: a train controlled by AI.
###
Crafty.c "AITrain",
  init: ->
    @requires("TrainHead")
  
  _getSegmentPriority: (depth, x, y, dir, distance) ->
    #takes in: the first segment after the split!
    # returns: the priority
    searchPlayer = (if @playerOne then "playerTwo" else "playerOne")
    dropoffPlayer = (if @playerOne then "dropoffP1" else "dropoffP2")
    results = AI.checkAlongSegment(x, y, dir)
    cdir = results.endpoint.dir[2]
    sdir = results.endpoint.dir[0]
    newx = results.endpoint.at().x
    newy = results.endpoint.at().y
    if (depth > 0)
      straightPriority = @_getSegmentPriority(depth-1, newx+Util.dirx(sdir), newy+Util.diry(sdir), sdir, results.distance)
      curvedPriority = @_getSegmentPriority(depth-1, newx+Util.dirx(cdir), newy+Util.diry(cdir), cdir, results.distance)
    else
      straightPriority = 0
      curvedPriority = 0
    priority = 0
    for station in results.stations
      priority += (Math.min(station.population, 100 - @passengers) + station[dropoffPlayer])
    if results.trainsFound[searchPlayer]
      if results.trainsFound[searchPlayer].oncoming
        # check OTHER train's distance to junction
        otherDist = AI.checkAlongSegment(x, y, Util.opposite(dir)).distance
        if (otherDist >= distance)
          priority -= 100
      else
        if distance < 4
          priority -= 50
        else if distance < 8
          priority -= 10
        else
          priority -= 5
    priority + Math.max(straightPriority + curvedPriority)
  
  _updateCurrentTrack: (dir) ->
    # AI decision-making process
    # look down both paths and get [trains, stations] recursively
    # Determine if enemy train is coming towards
    backThroughCurve = (@reversing and !(@_hasCurveOption() and @_hasStraightOption()) and @currentTrack.dir.length == 3)
    if backThroughCurve
      for f in @followers
        f.curves.shift()
    @currentTrack = Util.trackAt(@currentTrack.at().x + Util.dirx(dir), @currentTrack.at().y + Util.diry(dir))
    if @_arriveAtStation? then @_arriveAtStation()
    straight = @_hasStraightOption()
    curve = @_hasCurveOption()
    if (straight and curve)
      # Fancy AI stuff goes here!
      straightPriority = @_getSegmentPriority(2, @currentTrack.at().x+Util.dirx(@sourceDirection), @currentTrack.at().y+Util.diry(@sourceDirection), @sourceDirection, 0)
      curvedPriority = @_getSegmentPriority(2, @currentTrack.at().x+Util.dirx(Util.getTargetDirection(@currentTrack, @sourceDirection)), @currentTrack.at().y+Util.diry(Util.getTargetDirection(@currentTrack, @sourceDirection)), Util.getTargetDirection(@currentTrack, @sourceDirection), 0)
      straightPriority += Math.random() * 20 - 10
      # Pick the proper path or a random one
      decision = (curvedPriority > straightPriority)
    @targetDirection = ((if (straight and curve and decision) or (curve and !straight) then Util.getTargetDirection(@currentTrack, @sourceDirection) else @sourceDirection))
    if straight and curve
      window.blamePlayerOne = false
      isCurving = @isCurving()
      for f in @followers
        f.curves.push isCurving
    return


###
Track section: a 1x1 piece of track with two or more dirs.
###
Crafty.c "TrackSection",
  init: ->
    @requires "2D, Grid"
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
    @requires "2D, Grid"
    @bind "EnterFrame", ->
      @populate() if (GameState.running and GameClock.hour > 5)
      return
    return

  setPopular: (popular) ->
    letter = @letter
    @popular = not @popular
    Crafty("spr_" + ((if @popular then "" else "p")) + "stop" + @letter).each ->
      @removeComponent "spr_" + ((if @popular then "" else "p")) + "stop" + letter, false
      @addComponent "spr_" + ((if @popular then "p" else "")) + "stop" + letter
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
    else if dir is "n"
      @attachToTrack(x, y - 1).attachToTrack x + 1, y - 1
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
    if (!window.HEADLESS_MODE)
      if @population / 12.0 is @t.length + 1
        remaining = Math.min(@population, 72) - (@t.length) * 12
        pos = @t.length
        if @facing is "w"
          x = @_x + 6 * (pos % 2)
          y = @_y + 2 + 8 * pos
        else if @facing is "e"
          x = @_x + 20 - 6 * (pos % 2)
          y = @_y + 2 + 8 * pos
        else if @facing is "n"
          x = @_x + 2 + 8 * pos
          y = @_y - 6 + 4 * (pos % 2)
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
    @css(
      textAlign: "center"
    )
    @display = 0
    @attr
      h: 47
      w: 200

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
    @attach(@bar)
    @attr z: 800
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
    GameClock.newDay()
    if (!window.HEADLESS_MODE)
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
      @bind "KeyDown", (e) ->
        if e.keyCode is Crafty.keys.SPACE and (GameState.running or @paused)
          if @pauseAvailable
            Crafty.audio.play("select")
            Crafty.e "PauseText"
            @pauseAvailable = false
            GameState.running = false
            @paused = true
          else if @paused
            Crafty.audio.play("select")
            Crafty("PauseText").teardown()
            Crafty("PauseText").destroy()
            GameState.running = true
            @paused = false
        return
      @text GameClock.hour + ((if GameClock.minute > 9 then ":" else ":0")) + GameClock.minute
    @tickDelay = 0
    @bind "EnterFrame", (data)->
      percentTimePassed = Math.max(0, (GameClock.hour - 6) / 4 + (GameClock.minute / 240))
      if GameState.running
        @tickDelay+=(data.dt / 20)
        GameClock.elapsed += (data.dt / 20)
      if GameState.running and (@tickDelay > Constants.MINUTE_LENGTH)
        GameClock.update()
        @tickDelay -= Constants.MINUTE_LENGTH
        Util.gameOver false  if GameClock.hour is 10
        if (!window.HEADLESS_MODE)
          @text GameClock.hour + ((if GameClock.minute > 9 then ":" else ":0")) + +GameClock.minute
          Crafty("AmbientLayer").each ->
            @color Util.sunrise(percentTimePassed)
            return
    
          Crafty("LightLayer").each ->
            @attr "alpha", 1 - percentTimePassed
            return

      return
    GameState.running = true

    return


###
Controls train movement. Makes sure all trains move before checking collision.
###
Crafty.c "TrainController",
  init: ->
    @bind "EnterFrame", (data) ->
      if GameState.running and GameClock.hour == 6 and GameClock.minute == 0
        if !window.BGMManager.isPlaying()
          window.BGMManager.playNext()
      if GameState.running and GameClock.hour > 5
        Crafty("Train").each ->
          if (@head.stayDelay > 0)
            @head.stayDelay -= 1
          else
            @moveAlongTrack @speed * data.dt / 20
          return

        Crafty("Train").each ->
          @attr("z", Math.floor(@y))
          if @checkCollision() and GameState.running
            Crafty.audio.play("crash")
            Util.gameOver true
          return

      return

    return

Crafty.c "EndingText",
  init: ->
    window.BGMManager.stop()
    Crafty.audio.play("endlevel")
    @requires("Dialog").textFont size: "20px"
    @display = 0
    @attr
      x: 0
      y: 112
      w: 268
      h: 160
    @firstText = Crafty.e('DOM, SelectableText').attr({x: 230, y: 250,w: 200, h:30, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Try Again").attr('idx', 0).unselectable()
    @secondText = Crafty.e('DOM, SelectableText').attr({x: 230, y: 280,w: 200, h: 30, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Select Map").attr('idx', 1).unselectable()
    @arrow = Crafty.e('DOM, SelectArrow').attr({x: 190, y: 250, z: 50, callbacks: [
      () ->
        Crafty("TrainController").destroy() # Because of the 2D issue
        Crafty.scene("PlayGame")
        true
      , () ->
        Crafty("TrainController").destroy() # Because of the 2D issue
        Crafty.scene("SelectMap")
        window.BGMManager.stop()
        window.BGMManager.playTitle()
        true
    ]})

    @css
      padding: 20
      margin: "0px 150px"
      width: 600
      height: 200
      boxShadow: "-8px 8px 0px rgba(47,32,16,0.35)"

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
    @attr(
      y: 24
      h: 380
    )
    @css(
      height: '350px'
    )
    @arrow.attr(
      y: 380
    )
    @firstText.attr(
      y: 380
    )
    @secondText.attr(
      y: 410
    )
    p1score = 0
    p2score = 0
    Crafty("TrainHead").each ->
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
        
    GraphTools.placeGraph(if p1score is p2score then (Math.random() > 0.5) else (if p1score > p2score then true else false))
    @text "The morning rush is over!<br/>Passengers delivered:<br/>Red: " + p1score + ", Blue: " + p2score + "<br/>" + ((if p1score is p2score then "It's a Draw!" else (((if p1score > p2score then "Red" else "Blue")) + " Line wins!")))
    return

Crafty.c "FailureText",
  init: ->
    @requires "EndingText"
    if (window.Blame)
      if (window.blamePlayerOne)
        dialogList = Constants.ENDING_DIALOGS[2]
      else
        dialogList = Constants.ENDING_DIALOGS[3]
    else
      dialogList = Constants.ENDING_DIALOGS[1]
    @text Constants.ENDING_DIALOGS[0][Math.floor(Math.random() * Constants.ENDING_DIALOGS[0].length)] + "<br/>" + dialogList[Math.floor(Math.random() * dialogList.length)]
    return

Crafty.c "BarController",
  init: ->
    @requires("2D, Canvas").attr z: 800
    return

  setup: ->
    @attr
      h: 20
      w: 20

    c = ((if @playerOne then "r" else "b"))
    @attach(Crafty.e("2D, Canvas, spr_barback").attr
      x: @x
      y: @y
      z: 801
    )
    @l = Crafty.e("2D, Canvas, spr_" + c + "barl").attr(
      x: @x
      y: @y
      z: 801
    )
    @b = Crafty.e("2D, Canvas, spr_" + c + "bar").attr(
      w: 0
      x: @x + 4
      y: @y
      z: 801
    )
    @r = Crafty.e("2D, Canvas, spr_" + c + "barr").attr(
      x: @x + 4
      y: @y
      z: 801
    )
    @attach(@l)
    @attach(@b)
    @attach(@r)
    this

  update: (fullness, ticks) ->
    @attr
      x: @x
      y: @y
      z: 801
    @l.attr
      x: @x
      y: @y
      z: 801
    @b.attr
      x: @x + 4
      w: ((if fullness > 4 then fullness * 2 - 8 else 0))
      z: 801
    @r.attr
      x: ((if fullness > 2 and ticks.length then @x - 4 + fullness * 2 else @x + 4))
      z: 801
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
          z: 801
        )
        previous = attempt
      if i < ticks.length - 1
        d += ticks[i][0] * 2
        @ticks.push Crafty.e("2D, Canvas, spr_" + ((if @playerOne then "r" else "b")) + "bart").attr(
          x: @x + d
          y: @y
          z: 801
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


###
A selector for a menu item.
Give it an array of callbacks for menu items.
###
Crafty.c "SelectArrow",
  init: ->
    @requires("2D, spr_selectarrow")
    @spaceIcon = Crafty.e('2D, ' + (if @has('DOM') then 'DOM' else 'Canvas') + ', spr_space').attr({x: 150, y: -10})
    @attach(@spaceIcon)
    @lineHeight = 30
    @itemCount = 2
    @selectedIndex = 0
    @callbacks = []
    @bind "KeyDown", (e) ->
      zeroPosition = @_y - (@selectedIndex * @lineHeight)
      if e.keyCode is Crafty.keys.P or e.keyCode is Crafty.keys.DOWN_ARROW
        @moveDown()
      else if e.keyCode is Crafty.keys.Q or e.keyCode is Crafty.keys.UP_ARROW
        @moveUp()
      else if e.keyCode is Crafty.keys.SPACE
        if @callbacks[@selectedIndex]
          if @callbacks[@selectedIndex]()
            Crafty.audio.play("select")
      return
  
  moveDown: (n)->
    count = (if n then n else 1)
    zeroPosition = @_y - (@selectedIndex * @lineHeight * count)
    Crafty.audio.play("arrowtick")
    @selectedIndex += count
    if (@selectedIndex >= @itemCount)
      @selectedIndex -= @itemCount
    @attr({y: zeroPosition + (@selectedIndex * @lineHeight)})
          
  moveUp: (n)->
    count = (if n then n else 1)
    zeroPosition = @_y - (@selectedIndex * @lineHeight * count)
    Crafty.audio.play("arrowtick")
    @selectedIndex -= count
    if (@selectedIndex < 0)
      @selectedIndex += @itemCount
    @attr({y: zeroPosition + (@selectedIndex * @lineHeight)})
Crafty.c "CheckBox",
  init: ->
    @requires("2D, Canvas, spr_checkbox")
    @callback = () ->
  _setChecked: (checked) ->
    if @has('spr_checkbox' + (if checked then '' else 'checked')) then @removeComponent('spr_checkbox' + (if checked then '' else 'checked'), false)
    @addComponent('spr_checkbox' + (if checked then 'checked' else ''))
  refresh: () ->
    @_setChecked(@callback())

Crafty.c "SelectableText",
  init: ()->
    @requires("Text, Mouse")
    @bind('Click', () ->
      console.log('activating #'+@idx)
      if Crafty("SelectArrow").callbacks[@idx]
        if Crafty("SelectArrow").callbacks[@idx]()
          Crafty.audio.play("select")
    )

Crafty.c "Scroller",
  init: ()->
    @requires("2D, Canvas, Mouse")
    @attr(
      x: 0
      y: 0
      w: 1000
      h: 1000
      offset: 0
      moving: false
      firstScroll: false
      initScroll: 96
    )
    @bind('MouseDown', (e)->
      @startScroll(e)
    )
    @bind('MouseMove', (e)->
      @moveScroll(e)
    )
    @bind('MouseUp', (e)->
      @endScroll(e)
    )
    
  startScroll: (e)->
    @didMovement = false
    @moving = true
    @lasty = e.y
    
  moveScroll: (e)->
    if @moving
      @didMovement = true
      window.AAA = @lasty - e.y
      this.offset += window.AAA;
      if (-20 < @offset < 410)
        Crafty('SelectArrow, spr_selectstn, spr_selectline, _MenuElement').each(() ->
          this.y -= window.AAA;
        )
      @lasty = e.y
      arrow = Crafty("SelectArrow")
      if arrow.y > 284
        arrow.moveUp()
      console.log(arrow.y)
      if arrow.y < (236)
        arrow.moveDown()
        if (@initScroll > 0)
          @initScroll -= 40
    
  endScroll: ()->
    if (@offset > 410) 
      @offset = 410
    if (@offset < -20)
      @offset = -20
    @moving = false