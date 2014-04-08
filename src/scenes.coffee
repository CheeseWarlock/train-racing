Crafty.scene('Title', () ->
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
        window.singlePlayerMode = true
        Crafty.scene('SelectMap')
      , () ->
        window.singlePlayerMode = false
        Crafty.scene('SelectMap')        
      , () ->
        Crafty.scene('SelectMode')
      , () ->
        Crafty.scene('Options')
    ]
  )
  
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 280,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("1-Player Start")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 310,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("2-Player Start")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 340,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Instructions")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 370,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Options")
  
  Crafty.e('2D, Keyboard').bind('KeyDown', (e) ->
    if e.keyCode == Crafty.keys.SPACE
      Crafty.audio.play("select")
      Crafty.scene('SelectMode')
  )
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
  Crafty.audio.toggleMute()
  Crafty.load(['img/ul.png', 'img/ppl.png', 'img/news.png'], () ->
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
    spritenames = {}
    test = () ->
      for a in [0..5]
        for b in [0..5]
          spritenames['spr_person'+a+b] = [a,b]
    test()
    Crafty.sprite(8,12,'img/ppl.png', 
      spritenames
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
      spr_pstopa: [0,1]
      spr_pstopb: [1,1]
      spr_pstopc: [2,1]
      spr_pstopd: [3,1]
      spr_pstope: [4,1]
      spr_pstopf: [5,1]
    )
    Crafty.sprite(88, 48, 'img/space.png',
      spr_space: [0,0]
    )
    Crafty.sprite(48, 40, 'img/keys.png',
      spr_keyp: [0,0]
      spr_keyq: [0,1]
      spr_arrowl: [1,0]
      spr_arrowr: [1,1]
    )
    Crafty.sprite(200, 12, 'img/barback.png',
      spr_barback: [0,0]
    )
    Crafty.sprite(176, 176, 'img/title.png',
      spr_title: [0,0]
    )
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
    Crafty.sprite(134, 68, 'img/coffee.png',
      spr_coffee: [0,0]
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
    else if Crafty('SelectArrow').y < 140 + Math.min(96, Crafty("SelectArrow").selectedIndex * 48)
      Crafty('SelectArrow, spr_selectstn, spr_selectline, _MenuElement').each(() ->
        this.y += 6;
      )
  )
  .textColor('#FFFDE8')
  curry = 140
  selectArrow = Crafty.e('Canvas, SelectArrow').attr({x: 200, y: 140, itemCount: window.MapList.length + 2, lineHeight: 48})
  selectArrow.spaceIcon.attr({x: 404})
  mapCallback = () ->
    $.getJSON(window.MapList[Crafty('SelectArrow').selectedIndex][0], (data) ->
      window.selectedMap = data
      Crafty.scene('PlayGame')
    )
  for idx of window.MapList
    Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
    Crafty.e('2D, Canvas, Text, _MenuElement').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#FFFDE8').text(window.MapList[idx][1])
    Crafty.e('2D, Canvas, spr_selectline').attr({x: 250, y: curry+24})
    curry+=48
    selectArrow.callbacks.push(mapCallback)
    titleText.titles.push(window.MapList[idx][1])
  Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
  Crafty.e('2D, Canvas, Text, _MenuElement').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Load Map...")
  titleText.titles.push("Load Map...")
  Crafty.e('2D, Canvas, spr_selectline').attr({x: 250, y: curry+24})
  Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry+48})
  Crafty.e('2D, Canvas, Text, _MenuElement').attr({x: 280, y: curry+48,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#E23228').text("Back to Title")
  titleText.titles.push("Back to Title")
  selectArrow.callbacks.push(
    () ->
      try
        window.selectedMap = JSON.parse($("#custom-level-data").val())
        Crafty.scene('PlayGame')
      catch
        if !($('#display-design:visible').length)
          $('#display-manual').hide()
          $('#display-credits').hide()
          $('#display-design').show()
          window.dontGoAway = true
  )
  selectArrow.callbacks.push(
    () ->
      Crafty.scene('Title')
  )
  
  Crafty.e('2D, Canvas, Color').color('#2B281D')
  .attr(
    y: 0
    x: 0
    w: 1000
    h: 130
  )
  Crafty.e('2D, Canvas, Color').color('#2B281D')
  .attr(
    y: 410
    x: 0
    w: 1000
    h: 150
  )
  
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 230, y: 430})
  Crafty.e('2D, Canvas, spr_keyp').attr({x: 338, y: 430})
  Crafty.e('2D, Canvas, spr_arrowr').attr({x: 230, y: 480})
  Crafty.e('2D, Canvas, spr_arrowl').attr({x: 338, y: 480})
  
  selectArrow.bind('KeyDown', () ->
    Crafty("LevelNameText").text(Crafty("LevelNameText").titles[Crafty("SelectArrow").selectedIndex])
  )
)

Crafty.scene('SelectMode', () ->
  Crafty.e('TitleText').attr({y: 198}).text('Select a mode:')
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 194, y: 250})
  Crafty.e('2D, DOM, Text').attr({x: 153, y: 298, w: 200}).text('One Player').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, Canvas, spr_keyp').attr({x: 375, y: 250})
  Crafty.e('2D, DOM, Text').attr({x: 327, y: 298, w: 200}).text('Two Pl').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, DOM, Text').attr({x: 407, y: 298, w: 200}).text('ayers').textFont({size: '26px', family: 'Aller'}).textColor('#4956FF')

  Crafty.e('2D, Keyboard').bind('KeyDown', (e) ->
    if e.keyCode == Crafty.keys.P
      Crafty.audio.play("select")
      Crafty.scene('SelectMap')
    if e.keyCode == Crafty.keys.Q
      Crafty.audio.play("select")
      window.singlePlayerMode = true
      Crafty.scene('SelectMap')
    if e.keyCode == Crafty.keys.SPACE
      if (Crafty.audio.muted)
        Crafty('checkybox').removeComponent('spr_checkbox', false).addComponent('spr_checkboxchecked')
      else
        Crafty('checkybox').removeComponent('spr_checkboxchecked', false).addComponent('spr_checkbox')
      Crafty.audio.toggleMute()
      Crafty.audio.play('arrowtick')
  )
  Crafty.e('2D, Canvas, Text').attr({x: 214, y: 440,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#FFFDE8').text("Sound")
  Crafty.e('2D, Canvas, spr_space').attr({x: 308, y: 430})
  Crafty.e('2D, Canvas, checkybox, spr_checkbox' + (if Crafty.audio.muted then '' else 'checked')).attr({x: 278, y: 440})
  
)

Crafty.scene('PlayGame', () ->
  Crafty.background('rgb(80, 160, 40)')
  builder = Crafty.e((if window.HEADLESS_MODE then "" else "2D, Canvas, ")+"TiledMapBuilder")
  builder.setMapDataSource(window.selectedMap).createWorld(Util.setupFromTiled)
  Crafty.e('TrainController')
  Crafty.e('ClockController')
  if (!window.HEADLESS_MODE)
    Crafty.e('2D, Canvas, spr_brushed').attr({w: 616, h: 84, y: 476, z: 800})
    Crafty.e('2D, Canvas, Color, AmbientLayer').attr({x:0,y:0,z:600,h:1000,w:1000}).color('rgba(3,29,51,0.5)')
  Util.assignStations()
  
)

Crafty.scene('Options', () ->
  selectArrow = Crafty.e('Canvas, SelectArrow').attr(
    x: 190
    y: 280
    itemCount: 4
    callbacks: [
      () ->
        Crafty.audio.toggleMute()
        Crafty('CheckBox').get(0).refresh()
      , () ->
        window.SwapColours = !window.SwapColours
        Crafty('CheckBox').get(1).refresh()
      , () ->
        window.Brakes = !window.Brakes
        Crafty('CheckBox').get(2).refresh()
      , () ->
        Crafty.scene('Title')
    ]
  )
  selectArrow.spaceIcon.attr({x: 378})
  Crafty.e('TitleText').attr({y: 100}).text("Options").textFont(
    size: '30px'
  )
  
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 280,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Sound On")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 310,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Swap Colours")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 340,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Brakes")
  Crafty.e('2D, DOM, Text').attr({x: 230, y: 370,w: 200, z: 50}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').textColor('#E23228').text("Back to Title")
  Crafty.e('2D, Canvas, CheckBox').attr({x: 346, y: 280, callback: () ->
    !Crafty.audio.muted
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 346, y: 310, callback: () ->
    window.SwapColours
  }).refresh()
  Crafty.e('2D, Canvas, CheckBox').attr({x: 346, y: 340, callback: () ->
    window.Brakes
  }).refresh()
  
)
