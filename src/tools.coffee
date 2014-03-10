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
          for i in [800,1600,2400]
            setTimeout(() ->
              Crafty('Train').each(() ->
                this._removeSpriteComponent()
              )
            , i)
          
          for i in [1200,2000,2800]
            setTimeout(() ->
              Crafty('Train').each(() ->
                this._addSpriteComponent()
              )
            , i)
            
          setTimeout(() ->
            Crafty.e('FailureText')
          , 2800)
          this
        else
          setTimeout(() ->
            Crafty.e('VictoryText')
          , 800)
  createTrain: (x, y, playerOne, dir) ->
    letter = (if playerOne then 'r' else 'b')
    
    train = Crafty.e('PlayerTrain').at(x, y).attr('playerOne', playerOne).attr('sourceDirection', dir)
    .attr('targetDirection', dir).addComponent('spr_' + letter + 'train' + dir)
    .findTrack().bindKeyboardTurn((if playerOne then Crafty.keys.Q else (if window.singlePlayerMode then null else Crafty.keys.P)))
    
    follow = Crafty.e('FollowTrain').at(x-Util.dirx(dir), y-Util.diry(dir)).attr('playerOne', playerOne).attr('sourceDirection', dir)
    .attr('targetDirection', dir)
    .findTrack().attr('front', train)
    
    end = Crafty.e('FollowTrain').at(x-2*Util.dirx(dir), y-2*Util.diry(dir)).attr('playerOne', playerOne).attr('sourceDirection', dir)
    .attr('targetDirection', dir).attr('finale', true)
    .findTrack().attr('front', follow)
    
    train.followers = [follow, end]

    follow.moveAlongTrack(6)
    end.moveAlongTrack(12)
    
    train
    
      
  setupFromTiled: (tiledmap) ->
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
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, true, 'e')
            when '10'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, true, 'n')
            when '11'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, true, 'w')
            when '12'
              firstTrain = Util.createTrain(tile.at().x, tile.at().y, true, 's')
            when '21'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, false, 'e')
            when '22'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, false, 'n')
            when '23'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, false, 'w')
            when '24'
              secondTrain = Util.createTrain(tile.at().x, tile.at().y, false, 's')
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
          train: firstTrain, playerOne: true
        ).setup()
      if secondTrain
        Crafty.e('PlayerScore').attr(
          "x":392,"y":512
        ).attr("train", secondTrain).setup()
    
  
  sunrise: (percent) ->
    if percent < 0.25
      'rgba(' + (3+ Math.floor(percent * 400)) + ',' + (29 + Math.floor(percent * 200)) + ',51,' + (1 - percent) / 2 + ')'
    else
      'rgba(' + (103 - Math.floor((percent - 0.25) * 300)) + ',' + (79 + Math.floor((percent - 0.25) * 60)) + ',' + (51 + Math.floor((percent - 0.25) * 150)) + ',' + (1 - percent) / 2 + ')'
    
     
window.Constants =
  DIR_PREFIXES: ['n','e','w','s']
  MINUTE_DELAY: 99
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
    'What kind of urban planner designed this place, anyway?!']]
  MAX_PASSENGERS: 100
  FULL_SPEED: 1.75
  REDUCED_SPEED: 0.875
  TILE_JUMP_LIMIT: 5
  
window.GameState =
  running: false  

window.GameClock = 
  newDay: () ->
    this.hour = 6
    this.minute = 0
  update: () ->
    if (this.minute >= 59)
      this.hour += 1
      this.minute = 0
    else
      this.minute += 1
      
$.getJSON('./maps.json', (mapListSource) ->
  window.MapList = mapListSource
)
