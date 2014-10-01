Crafty.scene('Title', () ->
  self.focus()
  if !window.gameAlreadyStarted
    window.BGMManager.playTitle()
    window.gameAlreadyStarted = true
  this.letters = ""
  Crafty.e('2D, Canvas, spr_title').attr({x:220})
  Crafty.e('TitleText').attr({y: 178}).text('Compete to deliver more passengers by 10:00 AM.')
  Crafty.e('TitleText').attr({y: 228}).text('But if the trains collide, nobody wins!')
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 230, y: 430})
  Crafty.e('2D, Canvas, spr_keyp').attr({x: 338, y: 430})
  Crafty.e('2D, Canvas, spr_arrowr').attr({x: 230, y: 480})
  Crafty.e('2D, Canvas, spr_arrowl').attr({x: 338, y: 480})
  
  Crafty.e('Canvas, SelectArrow').attr(
    x: 190
    y: 280
    itemCount: 4
    callbacks: [
      () ->
        window.singlePlayerMode = false
        Crafty.scene('SelectMap')
        true
      , () ->
        window.singlePlayerMode = true
        Crafty.scene('SelectMap')   
        true     
      , () ->
        Crafty.scene('Instructions')
        true
      , () ->
        Crafty.scene('Options')
        true
    ]
  )
  
  Crafty.e('2D, Canvas, SelectableText').attr({x: 230, y: 280,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Start 2-Player").attr('idx',0)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 230, y: 310,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Start Vs. AI").attr('idx',1)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 230, y: 340,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Instructions").attr('idx',2)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 230, y: 370,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Options").attr('idx',3)
)

Crafty.scene('Loading', () ->
  Crafty.audio.create("get1", "assets/get1.wav")
  Crafty.audio.create("get2", "assets/get2.wav")
  Crafty.audio.create("get3", "assets/get3.wav")
  Crafty.audio.create("crash", "assets/crash.wav")
  Crafty.audio.create("select", "assets/select.wav")
  Crafty.audio.create("arrowtick", "assets/arrowtick.wav")
  Crafty.audio.create("brakeson", "assets/brakeson.wav")
  Crafty.audio.create("brakesoff", "assets/brakesoff.wav")
  Crafty.audio.create("start", "assets/start.wav")
  Crafty.audio.create("cappuccino", "assets/cappuccino.wav")
  Crafty.audio.create("express", "assets/express.wav")
  Crafty.audio.create("fiveoclock", "assets/fiveoclock.wav")
  createjs.Sound.registerSound
    src: "assets/express.wav"
    id: "express"
  createjs.Sound.registerSound
    src: "assets/cappuccino.wav"
    id: "cappuccino"
  createjs.Sound.registerSound
    src: "assets/fiveoclock.wav"
    id: "fiveoclock"
  createjs.Sound.registerSound
    src: "assets/start.wav"
    id: "start"
  Crafty.load(['img/ul.png', 'img/ullight.png', 'img/wordart.png', 'img/keys.png', 'img/mapselect.png'], () ->
    Crafty.sprite(28, 'img/ul.png',
      spr_rtrain: [2,0]
      spr_rtrainside: [3,0]
      spr_rtraine: [2,1]
      spr_rtrainn: [3,1]
      spr_rtrainw: [4,1]
      spr_rtrains: [5,1]
      spr_btrain: [2,2]
      spr_btrainside: [3,2]
      spr_btraine: [2,3]
      spr_btrainn: [3,3]
      spr_btrainw: [4,3]
      spr_btrains: [5,3]
      spr_arrowsign: [3,4]
      spr_platform: [4,6]
      spr_platformu: [2,7,2,1]
      spr_platformd: [4,7,2,1]
      spr_platforml: [4,5,1,2]
      spr_platformr: [5,5,1,2]
    )
    Crafty.sprite(4,12, 'img/bars.png',
      spr_rbarl: [0,0]
      spr_rbar: [1,0]
      spr_rbart: [2,0]
      spr_rbarr: [3,0]
      spr_bbarl: [0,1]
      spr_bbar: [1,1]
      spr_bbart: [2,1]
      spr_bbarr: [3,1]
    )
    Crafty.sprite(16, 16, 'img/stops.png',
      spr_stopa: [0,0]
      spr_stopb: [1,0]
      spr_stopc: [2,0]
      spr_stopd: [3,0]
      spr_stope: [4,0]
      spr_stopf: [5,0]
      spr_person00: [6,0]
      spr_pstopa: [0,1]
      spr_pstopb: [1,1]
      spr_pstopc: [2,1]
      spr_pstopd: [3,1]
      spr_pstope: [4,1]
      spr_pstopf: [5,1]
    )
    Crafty.sprite(88, 40, 'img/keys.png',
      spr_space: [0,0]
    , 0, 80, true)
    Crafty.sprite(48, 40, 'img/keys.png',
      spr_keyp: [0,0]
      spr_keyq: [0,1]
      spr_arrowl: [1,0]
      spr_arrowr: [1,1]
    )
    Crafty.sprite(200, 12, 'img/barback.png',
      spr_barback: [0,0]
    )
    Crafty.sprite(176, 176, 'img/wordart.png',
      spr_title: [0,0]
    )
    Crafty.sprite(134, 68, 'img/wordart.png',
      spr_coffee: [0,0]
    , 0, 176, true)
    Crafty.sprite(616, 84, 'img/brushed.png',
      spr_brushed: [0,0]
    )
    Crafty.sprite(24, 24, 'img/mapselect.png',
      spr_selectstn: [0,0]
      spr_selectarrow: [1,0]
      spr_selectline: [0,1]
      spr_selectstn2: [1,1]
      spr_checkbox: [0,2]
      spr_checkboxchecked: [1,2]
    )
    Crafty.sprite(44, 44, 'img/tabletbuttons.png',
      spr_redbutton: [0,0]
      spr_bluebutton: [1,0]
    )
    Crafty.sprite(28, 28, 'img/ullight.png',
      spr_rtrainlight: [2,0]
      spr_rtrainsidelight: [3,0]
      spr_rtrainelight: [2,1]
      spr_rtrainnlight: [3,1]
      spr_rtrainwlight: [4,1]
      spr_rtrainslight: [5,1]
      spr_btrainlight: [2,2]
      spr_btrainsidelight: [3,2]
      spr_btrainelight: [2,3]
      spr_btrainnlight: [3,3]
      spr_btrainwlight: [4,3]
      spr_btrainslight: [5,3]
      spr_light29: [4,4]
      spr_light30: [5,4]
      spr_light33: [2,5]
      spr_light34: [3,5]
      spr_light35: [4,5]
      spr_light36: [5,5]
      spr_light39: [2,6]
      spr_light40: [3,6]
      spr_light41: [4,6]
      spr_light42: [5,6]
      spr_light43: [0,7]
      spr_light44: [1,7]
      spr_light45: [2,7]
      spr_light46: [3,7]
      spr_light47: [4,7]
      spr_light48: [5,7]
      spr_light49: [0,8]
      spr_light50: [1,8]
      spr_light53: [4,8]
      spr_light54: [5,8]
      spr_light62: [1,10]
      spr_light63: [2,10]
      spr_light64: [3,10]
      spr_light67: [0,11]
      spr_light68: [1,11]
      spr_light69: [2,11]
      spr_light73: [0,12]
      spr_light74: [1,12]
      spr_light76: [3,12]
      spr_light79: [0,13]
      spr_light80: [1,13]
      
    )
    Crafty.c('LightLayer')
    Crafty.c('AmbientLayer')
    Crafty.scene('Title')
    this
  )
)

Crafty.scene('SelectMap', () ->
  Crafty.background('#2B281D')
  
  Crafty.e('2D, DOM, Color').color('#2B281D')
  .attr(
    y: 0
    x: 0
    w: 1000
    h: 130
  )
  Crafty.e('2D, DOM, Color').color('#2B281D')
  .attr(
    y: 410
    x: 0
    w: 1000
    h: 150
  )
  
  Crafty.e('Scroller')
  
  Crafty.e('TitleText').text('Select a map:')
  .attr(
    y: 30
  )
  titleText = Crafty.e('TitleText, Keyboard, LevelNameText').text(window.MapList[0][1]).attr(
    y: 86
    titles: []
  )
  .textColor('#FFFDE8')
  .textFont(
    size: '30px'
  ).bind('EnterFrame', () ->
    if Crafty('SelectArrow').y > 284
      Crafty('SelectArrow, spr_selectstn, spr_selectline, _MenuElement').each(() ->
        this.y -= 6;
      )
      Crafty("Scroller").each(() ->
        @offset += 6
      )
    else if Crafty('SelectArrow').y < 236
      Crafty('SelectArrow, spr_selectstn, spr_selectline, _MenuElement').each(() ->
        this.y += 6;
      )
      Crafty("Scroller").each(() ->
        @offset -= 6
      )
  )
  .textColor('#FFFDE8')
  curry = 236
  selectArrow = Crafty.e('Canvas, SelectArrow').attr({x: 200, y: 236, itemCount: window.MapList.length + 1, lineHeight: 48})
  selectArrow.spaceIcon.attr({x: 404})
  mapCallbackMaker = (i) ->
    () ->
      if (!Crafty("Scroller").didMovement)
        $.getJSON(window.MapList[i][0], (data) ->
          window.selectedMap = data
          Crafty.scene('PlayGame')
        )
        return true
      false
  for idx of window.MapList
    Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
    Crafty.e('2D, Canvas, SelectableText, _MenuElement').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#FFFDE8').text(window.MapList[idx][1]).attr('idx',idx)
    Crafty.e('2D, Canvas, spr_selectline').attr({x: 250, y: curry+24})
    curry+=48
    selectArrow.callbacks.push(mapCallbackMaker(idx))
    titleText.titles.push(window.MapList[idx][1])
  Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
  Crafty.e('2D, Canvas, SelectableText, _MenuElement').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#E23228').text("Back to Title").attr('idx',++idx)
  titleText.titles.push("Back to Title")
  selectArrow.callbacks.push(
    () ->
      Crafty.scene('Title')
      true
  )
  
  Crafty.e('2D, DOM, spr_keyq').attr({x: 230, y: 430})
  Crafty.e('2D, DOM, spr_keyp').attr({x: 338, y: 430})
  Crafty.e('2D, DOM, spr_arrowr').attr({x: 230, y: 480})
  Crafty.e('2D, DOM, spr_arrowl').attr({x: 338, y: 480})
  
  Crafty("SelectableText").each( ()->
    @bind('MouseDown', (e)->
      Crafty("Scroller").startScroll(e)
    )  
    @bind('MouseMove', (e)->
      Crafty("Scroller").moveScroll(e)
    )
    @bind('MouseUp', (e)->
      Crafty("Scroller").endScroll(e)
    )
  )
)

Crafty.scene('PlayGame', () ->
  window.BGMManager.stop()
  Crafty.background('rgb(80, 160, 40)')
  builder = Crafty.e((if window.HEADLESS_MODE then "" else "2D, Canvas, ")+"TiledMapBuilder")
  builder.setMapDataSource(window.selectedMap).createWorld(Util.setupFromTiled)
  Crafty.e('TrainController')
  Crafty.e('ClockController')
  if (!window.HEADLESS_MODE)
    Crafty.e('2D, Canvas, spr_brushed').attr({w: 616, h: 84, y: 476, z: 800})
    Crafty.e('2D, Canvas, Color, AmbientLayer').attr({x:0,y:0,z:600,h:1000,w:1000}).color('rgba(3,29,51,0.5)')
  Util.assignStations()
  if (window.TabletControls)
    Crafty.e('2D, Canvas, Mouse, spr_redbutton').bind('MouseDown', () ->
      if GameState.running
        Crafty.audio.play('brakeson')
        Crafty("PlayerTrain RedTrain")._setBraking true  
    ).bind('MouseUp', () ->
      if GameState.running
        Crafty.audio.play('brakesoff')
        Crafty("PlayerTrain RedTrain")._setBraking false  
    ).bind('MouseOut', () ->
      if GameState.running
        if Crafty("PlayerTrain RedTrain").isBraking()
          Crafty.audio.play('brakesoff')
        Crafty("PlayerTrain RedTrain")._setBraking false  
    ).attr(
      x: 4
      y: 512
      z: 810
    )
    if (!window.singlePlayerMode)
      Crafty.e('2D, Canvas, Mouse, spr_bluebutton').bind('MouseDown', () ->
        if GameState.running
          Crafty.audio.play('brakeson')
          Crafty("PlayerTrain BlueTrain")._setBraking true  
      ).bind('MouseUp', () ->
        if GameState.running
          Crafty.audio.play('brakesoff')
          Crafty("PlayerTrain BlueTrain")._setBraking false  
      ).bind('MouseOut', () ->
        if GameState.running
          if Crafty("PlayerTrain BlueTrain").isBraking()
            Crafty.audio.play('brakesoff')
          Crafty("PlayerTrain BlueTrain")._setBraking false  
      ).attr(
        x: 568
        y: 512
        z: 810
      )
    Crafty("PlayerScore").each( ()->
      @attr('y', 490)
    )
)

Crafty.scene('Options', () ->
  selectArrow = Crafty.e('Canvas, SelectArrow').attr(
    x: 170
    y: 280
    itemCount: 7
    callbacks: [
      () ->
        Crafty.audio.toggleMute()
        Crafty('CheckBox').get(0).refresh()
        true
      , () ->
        window.SwapColours = !window.SwapColours
        Crafty('CheckBox').get(1).refresh()
        true
      , () ->
        window.Brakes = !window.Brakes
        Crafty('CheckBox').get(2).refresh()
        true
      , () ->
        window.StationStop = !window.StationStop
        Crafty('CheckBox').get(3).refresh()
        true
      , () ->
        window.TabletControls = !window.TabletControls
        Crafty('CheckBox').get(4).refresh()
        true
      , () ->
        window.Blame = !window.Blame
        Crafty('CheckBox').get(5).refresh()
        true
      , () ->
        Crafty.scene('Title')
        true
    ]
  )
  selectArrow.spaceIcon.attr({x: 398})
  Crafty.e('TitleText').attr({y: 100}).text("Options").textFont(
    size: '30px'
  )
  
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 280,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Sound On").attr('idx',0)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 310,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Randomize Colours").attr('idx',1)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 340,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Brakes").attr('idx',2)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 370,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Station Stop").attr('idx',3)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 400,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Tablet Controls").attr('idx',4)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 430,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Assign Blame").attr('idx',5)
  Crafty.e('2D, Canvas, SelectableText').attr({x: 210, y: 460,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').textColor('#E23228').text("Back to Title").attr('idx',6)
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 280, callback: () ->
    !Crafty.audio.muted
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 310, callback: () ->
    window.SwapColours
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 340, callback: () ->
    window.Brakes
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 370, callback: () ->
    window.StationStop
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 400, callback: () ->
    window.TabletControls
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 366, y: 430, callback: () ->
    window.Blame
  }).refresh()
)

Crafty.scene('Instructions', () ->
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 194, y: 180})
  Crafty.e('2D, DOM, Text').attr({x: 161, y: 228, w: 200}).text('Red Train').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, Canvas, spr_keyp, nobots').attr({x: 375, y: 180})
  Crafty.e('2D, DOM, Text, nobots').attr({x: 338, y: 228, w: 200}).text('Blue Train').textFont({size: '26px', family: 'Aller'}).textColor('#4956FF')

  Crafty.e('TitleText').attr({y: 136}).text('Hold your key to slow down and turn at junctions:')
  Crafty.e('TitleText').attr({y: 280}).text('Pick up and drop off passengers by driving through stations.')
  Crafty.e('TitleText').attr({y: 310}).text('Passenger destinations are shown at the bottom.')
  Crafty.e('TitleText').attr({y: 340}).text('Be aware of your opponent\'s position to avoid collisions.')
  Crafty.e('2D, Canvas, Mouse, spr_space').attr({x: 264, y: 400}).bind('KeyDown', (e) ->
    if e.keyCode is Crafty.keys.SPACE
      Crafty.audio.play('select')
      Crafty.scene('Title')
  ).bind('MouseDown', (e) ->
    Crafty.audio.play('select')
    Crafty.scene('Title')
  )
  Crafty.e('TitleText, Mouse').attr({y: 444, h: 30}).text('Back').bind('MouseDown', (e) ->
    Crafty.audio.play('select')
    Crafty.scene('Title')
  )
)
