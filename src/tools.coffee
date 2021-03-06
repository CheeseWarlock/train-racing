# Util functions

window.Util =
  opposite:
    (dir) -> switch dir
      when 'e' then 'w'
      when 'w' then 'e'
      when 'n' then 's'
      else 'n'
      
  endAngle:
    (dir) -> switch dir
      when 'e' then 0
      when 's' then Math.PI / 2
      when 'w' then Math.PI
      else Math.PI * 3/2
  
  trackAt:
    (x, y) ->
      result = null
      Crafty("TrackSection").each(
        () ->
          if (this.at().x == x && this.at().y == y)
            result = this
      )
      result
      
  dirx:
    (dir) -> switch dir
      when 'e' then 1
      when 'w' then -1
      else 0
      
  diry:
    (dir) -> switch dir
      when 'n' then -1
      when 's' then 1
      else 0
      
  heading:
    (x, y) ->
      if x == -1 then 'w'
      else if x == 1 then 'e'
      else if y == -1 then 'n'
      else if y == 1 then 's'
      else null
  
  getTargetDirection:
    (track, dir) ->
      idx = track.dir.indexOf(Util.opposite(dir))
      (if idx == track.dir.length-1 then track.dir[idx-1] else track.dir[idx+1])
      
  assignStations:
    () ->
      i = 0
      Crafty('Station').each(
        () ->
          if (!window.HEADLESS_MODE)
            Crafty.e('2D, Canvas, spr_stop' + ['a','b','c','d','e','f'][i]).attr({x: this.x + (if (this.facing == 'e' || this.facing == 'w') then 6 else 20), y: this.y - 20, z: 999});
          this.letter = ['a','b','c','d','e','f'][i++]
      )
  
  gameOver:
    (failure) ->
      if (GameState.running)
        GameState.running = false
        if (failure)
          setTimeout(() ->
            Crafty.e('FailureText')
          , 1000)
          this
        else
          setTimeout(() ->
            Crafty.e('VictoryText')
          , 2500)
  createTrain: (x, y, playerOne, dir, cars=3) ->
    letter = (if playerOne then 'r' else 'b')
    
    train = Crafty.e((if playerOne or !(window.singlePlayerMode) then 'PlayerTrain' else 'AITrain') + (if playerOne then ', RedTrain' else ', BlueTrain')).at(x, y).attr('playerOne', playerOne).attr('sourceDirection', dir)
    .attr('targetDirection', dir)
    .findTrack()
    
    if playerOne or !(window.singlePlayerMode) then train.bindKeyboardTurn((if playerOne then Crafty.keys.Q else Crafty.keys.P))
    
    train.moveAlongTrack(0)
    
    train.followers = []
    front = train
    train.attr('head', train)
    for i in (if cars > 1 then [2..Math.max(2,cars)] else [])
      temp = Crafty.e('FollowTrain' + (if playerOne then ', RedTrain' else ', BlueTrain')).at(x, y).attr('playerOne', playerOne).attr('sourceDirection', dir)
      .attr('targetDirection', dir)
      .findTrack().attr('front', front)
      .attr('head', train)
      if (i == 2)
        temp.addComponent("CarryingTrain")
      front = temp
      train.followers.push(front)
      front.moveAlongTrack(-22 * (i-1))
      front.distanceTraveled = 0
    
    train
    
      
  setupFromTiled: (tiledmap) ->
    actuallySwapColours = (window.SwapColours and Math.random() > 0.5)
    for tile in tiledmap.getEntitiesInLayer('Tracks')
      tile.addComponent('TrackSection')
      for prop of tile.__c
        if prop.substring(0,4) == 'Tile'
          tilecode = prop.substring(4)
          switch tilecode
            when '1' then tile.dir = ['e', 's']
            when '2' then tile.dir = ['w', 's']
            when '7' then tile.dir = ['n', 'e']
            when '8' then tile.dir = ['n', 'w']
            when '13' then tile.dir = ['e', 'w']
            when '14' then tile.dir = ['n', 's']
            when '19' then tile.dir = ['w', 'e', 'n']
            when '20' then tile.dir = ['w', 'e', 's']
            when '25' then tile.dir = ['s', 'n', 'e']
            when '26' then tile.dir = ['s', 'n', 'w']
            when '27' then tile.dir = ['s', 'n', 'e', 'w']
            when '31' then tile.dir = ['e', 'w', 's']
            when '32' then tile.dir = ['e', 'w', 'n']
            when '37' then tile.dir = ['n', 's', 'e']
            when '38' then tile.dir = ['n', 's', 'w']
    for tile in tiledmap.getEntitiesInLayer('Stations')
      for prop of tile.__c
        if prop.substring(0,4) == 'Tile'
          tilecode = prop.substring(4)
          if tilecode in ['29','30','33','34','35','36','39','40','41','42','43','44','45','46','47','48','49','50','53','54','62','63','64'] and (!window.HEADLESS_MODE)
            Crafty.e('2D, Canvas, LightLayer, spr_light' + tilecode).attr({x:tile.x, y:tile.y, z:801})
          switch tilecode
            when '35' then tile.addComponent('Station').setupAttach('w')
            when '36' then tile.addComponent('Station').setupAttach('e')
            when '45' then tile.addComponent('Station').setupAttach('n')
            when '47' then tile.addComponent('Station').setupAttach('s')
    for tile in tiledmap.getEntitiesInLayer('Trains')
      tile.addComponent('Actor')
      for prop of tile.__c
        if prop.substring(0,4) == 'Tile'
          tilecode = prop.substring(4)
          switch tilecode
            when '9'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, !actuallySwapColours, 'e')
            when '10'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, !actuallySwapColours, 'n')
            when '11'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, !actuallySwapColours, 'w')
            when '12'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, !actuallySwapColours, 's')
            when '21'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, actuallySwapColours, 'e')
            when '22'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, actuallySwapColours, 'n')
            when '23'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, actuallySwapColours, 'w')
            when '24'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, actuallySwapColours, 's')
          tile.destroy()
    if tiledmap.getEntitiesInLayer('Props')
      for tile in tiledmap.getEntitiesInLayer('Props')
        tile.attr('z', 9)
        for prop of tile.__c
          if prop.substring(0,4) == 'Tile'
            tilecode = prop.substring(4)
            if tilecode in ['29','30','33','34','25','36','39','40','41','42','43','44','45','46','47','48','49','50','53','54','62','63','64', '67', '68', '69', '73', '74', '76', '79', '80']
              Crafty.e('2D, Canvas, LightLayer, spr_light' + tilecode).attr({x:tile.x, y:tile.y, z:801})
    if (!window.HEADLESS_MODE)
      if firstTrain
        Crafty.e('PlayerScore').attr(
          "x":0,"y":512
        ).attr(
          train: (if actuallySwapColours then secondTrain else firstTrain), playerOne: true
        ).setup()
      if secondTrain
        Crafty.e('PlayerScore').attr(
          "x":392,"y":512
        ).attr(
          train: (if actuallySwapColours then firstTrain else secondTrain), playerOne: false
        ).setup()
    
  
  sunrise: (percent) ->
    if percent < 0.25
      'rgba(' + (3+ Math.floor(percent * 400)) + ',' + (29 + Math.floor(percent * 200)) + ',51,' + (1 - percent) / 2 + ')'
    else
      'rgba(' + (103 - Math.floor((percent - 0.25) * 300)) + ',' + (79 + Math.floor((percent - 0.25) * 60)) + ',' + (51 + Math.floor((percent - 0.25) * 150)) + ',' + (1 - percent) / 2 + ')'
    
     
window.Constants =
  DIR_PREFIXES: ['n','e','w','s']
  COLLISION_SIZE: 22
  TILE_HALF: 14
  CURVE_QUARTER: 28 * Math.PI / 4
  ENDING_DIALOGS:
    [['Oh no!',
    'The trains collided!',
    'You caused an accident!',
    'What a disaster!',
    'That wasn\'t supposed to happen!'],
    ['If anyone asks, you weren\'t having a competition.',
    'You know, this is really everyone\'s fault.',
    'You know, this is really everyone\'s fault. Even the passengers.',
    'Some passengers were jostled, many more were late for work.',
    'Remember, you\'re supposed to AVOID each other.',
    'What kind of urban planner designed this place, anyway?!'],
    ['If only the red train had planned ahead a bit better...'],
    ['This one\'s definitely the blue train\'s fault...']]
  MAX_PASSENGERS: 100
  FULL_SPEED: 1.75
  REDUCED_SPEED: 0.875
  TILE_JUMP_LIMIT: 5
  MINUTE_LENGTH: 24
  
window.GameState =
  running: false  

window.GameClock = 
  elapsed: 0
  newDay: () ->
    this.hour = 5
    this.minute = 52
  update: () ->
    if (this.minute >= 59)
      this.hour += 1
      this.minute = 0
    else
      this.minute += 1
      
window.AI =
  checkAlongSegment: (x, y, dir) ->
    trainPositions = []
    stations = []
    trainPresences =
      playerOne:
        false
      playerTwo:
        false
    Crafty("Train").each () ->
      trainPositions.push [@currentTrack.at().x, @currentTrack.at().y, @playerOne, @targetDirection]
    dist = 0
    heading = dir
    track = Util.trackAt(x, y)
    while (track.dir.length != 3 or track.dir[1] != Util.opposite(heading))
      if (track.station) then stations.push(track.station)
      if track.dir.length == 2
        heading = (if Util.opposite(heading) == track.dir[0] then track.dir[track.dir.length - 1] else track.dir[0])
      else if track.dir.length == 3
        heading = track.dir[1]
      dist += 1
      x += Util.dirx(heading)
      y += Util.diry(heading)
      for trainPosition in trainPositions
        if trainPosition[0] == x and trainPosition[1] == y
          # Determine whether this train is on the path!
          trainPresences[(if trainPosition[2] then "playerOne" else "playerTwo")] = 
            oncoming: (trainPosition[3] == Util.opposite(heading))
            distance: dist
      track = Util.trackAt(x, y)
    distance:
      dist
    endpoint:
      track
    trainsFound:
      trainPresences
    stations:
      stations
      
window.GraphTools =
  drawGraph: (data, target, options) ->
    dataCopy = data.slice()
    data.unshift [
      0
      0
      0
    ]
    dataCopy.push [
      240
      0
      0
    ]
    c2 = target.getContext("2d")
    c2.strokeStyle = options.color
    c2.fillStyle = "rgba" + options.color.slice(3, -1) + ",0.5)"
    c2.lineWidth = 2
    c2.beginPath()
    y = 100
    c2.moveTo 0, y
    count = 0
    tr = undefined
    for i of dataCopy
      tr = dataCopy[i]
      count += tr[1] - tr[2]
      y -= tr[1] * options.y
      c2.lineTo tr[0] * options.x, y
    y += count * options.y
    c2.lineTo tr[0] * options.x, y
    tickPoint = [
      tr[0] * options.x
      y
    ]
    dataCopy.reverse()
    for i of dataCopy
      tr = dataCopy[i]
      y += tr[2] * options.y
      c2.lineTo dataCopy[parseInt(i) + 1][0] * options.x, y  if dataCopy[parseInt(i) + 1]
    c2.closePath()
    c2.fill()
    c2.beginPath()
    c2.moveTo(tickPoint[0], tickPoint[1])
    y = tickPoint[1]
    for i of dataCopy
      tr = dataCopy[i]
      y += tr[2] * options.y
      c2.lineTo dataCopy[parseInt(i) + 1][0] * options.x, y  if dataCopy[parseInt(i) + 1]
    c2.stroke()
    c2.beginPath()
    c2.moveTo tickPoint[0], tickPoint[1]
    c2.lineTo tickPoint[0] + 8, tickPoint[1]
    c2.closePath()
    c2.stroke()
    return

  drawHourLines: (target, options) ->
    c2 = target.getContext("2d")
    c2.translate 2, 0
    c2.strokeStyle = "rgba(255,253,232,0.5)"
    c2.lineWidth = 1
    i = 0

    while i <= 4
      c2.beginPath()
      c2.moveTo 60 * i * options.x, 0
      c2.lineTo 60 * i * options.x, 500 * options.y
      c2.closePath()
      c2.stroke()
      i++
    return

  drawPixelated: (img, context, zoom, x, y) ->
    zoom = 4  unless zoom
    x = 0  unless x
    y = 0  unless y
    ctx = document.createElement("canvas").getContext("2d")
    ctx.width = img.width
    ctx.height = img.height
    ctx.drawImage img, 0, 0
    idata = ctx.getImageData(0, 0, img.width, img.height).data
    context.fillStyle = "#2B281D"
    context.fillRect -10, -10, 1000, 1000
    x2 = 0

    while x2 < img.width
      y2 = 0

      while y2 < img.height
        i = (y2 * img.width + x2) * 4
        r = idata[i]
        g = idata[i + 1]
        b = idata[i + 2]
        a = idata[i + 3]
        context.fillStyle = "rgba(" + r + "," + g + "," + b + "," + (a / 255) + ")"
        context.fillRect x + x2 * zoom, y + y2 * zoom, zoom, zoom
        ++y2
      ++x2
    return

  drawGraphContents: (target, p1wins) ->
    c2 = target.getContext("2d")
    redT = undefined
    blueT = undefined
    Crafty("CarryingTrain").each ->
      if @playerOne
        redT = @trans
      else
        blueT = @trans
      return

    @drawHourLines target,
      x: 0.4
      y: 0.2
      
    @drawGraph (if p1wins then blueT else redT), target,
      color: (if p1wins then "rgb(73,86,255)" else "rgb(226,50,40)")
      x: 0.4
      y: 0.2

    @drawGraph (if p1wins then redT else blueT), target,
      color: (if p1wins then "rgb(226,50,40)" else "rgb(73,86,255)")
      x: 0.4
      y: 0.2

    @drawPixelated target, target.getContext("2d"), 2
    return

  placeGraph: (p1wins)->
    setTimeout (->
      fff = $(".VictoryText")
      $("<canvas id=\"graph\" height=220 width=220></canvas>").appendTo fff
      GraphTools.drawGraphContents(document.getElementById("graph"), p1wins)
      return
    ), 50
    return

  idataById: {}
  lastImageId: 0
  
window.BGMManager =
  playTitle: () ->
    @stop()
    if !Crafty.audio.muted
      @currentSong = createjs.Sound.play("start", {loop: -1})
  _play: () ->
    createjs.Sound.play((if @songIndex == 0 then "cappuccino" else if @songIndex == 1 then "express" else "fiveoclock"))
  playNext: () ->
    if (!@songIndex?)
      @songIndex = -1
    @stop()
    if !Crafty.audio.muted
      @songIndex = (++@songIndex % 3)
      @currentSong = @_play()
  stop: () ->
    if (@currentSong)
      @currentSong.stop()
  isPlaying: () ->
    (@currentSong? && @currentSong.playState == createjs.Sound.PLAY_SUCCEEDED)

$.getJSON('./maps.json', (mapListSource) ->
  window.MapList = mapListSource
)
