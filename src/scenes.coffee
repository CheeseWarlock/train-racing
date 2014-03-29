Crafty.scene('Title', () ->
  this.letters = ""
  Crafty.e('2D, Canvas, spr_title').attr({x:220})
  Crafty.e('TitleText').attr({y: 163}).text('Compete to deliver more passengers by 10:00 AM!')
  Crafty.e('TitleText').attr({y: 218}).text('Hold your key to slow down and turn at junctions:')
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 194, y: 270})
  Crafty.e('2D, DOM, Text').attr({x: 161, y: 318, w: 200}).text('Red Train').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, Canvas, spr_keyp, nobots').attr({x: 375, y: 270})
  Crafty.e('2D, DOM, Text, nobots').attr({x: 338, y: 318, w: 200}).text('Blue Train').textFont({size: '26px', family: 'Aller'}).textColor('#4956FF')
  Crafty.e('TitleText').attr({y: 376}).text('Your passengers\' destinations are shown at the bottom.')
  Crafty.e('TitleText').attr({y: 431}).text('Avoid collisions at all costs!')
  Crafty.e('2D, Canvas, spr_space').attr({x: 264, y: 483})
  
  Crafty.e('2D, Keyboard').bind('KeyDown', (e) ->
    if e.keyCode == Crafty.keys.SPACE
      Crafty.scene('SelectMode')
  )
)

Crafty.scene('Loading', () ->
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
    Crafty.sprite(176, 114, 'img/title.png',
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
  Crafty.c('MapSelectScrollable')
  
  curry = 140
  for idx of window.MapList
    Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
    Crafty.e('2D, Canvas, Text, aaa').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#FFFDE8').text(window.MapList[idx][1])
    Crafty.e('2D, Canvas, spr_selectline').attr({x: 250, y: curry+24})
    curry+=48
  Crafty.e('2D, Canvas, spr_selectstn').attr({x: 250, y: curry})
  Crafty.e('2D, Canvas, Text, aaa').attr({x: 280, y: curry,w: 200}).textFont({size: '17px', family: 'Aller'}).textColor('#5CC64C').text("Load Map...")
  Crafty.e('2D, Canvas, spr_selectarrow').attr({x: 200, y: 140})
  Crafty.e('2D, Canvas, spr_space').attr({x: 420, y: 130})
  
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
  Crafty.e('TitleText').text('Select a map:')
  .attr(
    y: 30
  )
  .textColor('#FFFDE8')
  Crafty.e('TitleText, Keyboard').text(window.MapList[0][1]).attr(
    y: 86
    selection: 0
  )
  .textColor('#FFFDE8')
  .textFont(
    size: '30px'
  )
  .bind('KeyDown', (e) ->
    if e.keyCode == Crafty.keys.SPACE
      if (!(window.MapList[this.selection]))
        try
          window.selectedMap = JSON.parse($("#custom-level-data").val())
          Crafty.scene('PlayGame')
        catch
          if !($('#display-design:visible').length)
            $('#display-manual').hide()
            $('#display-credits').hide()
            $('#display-design').show()
            window.dontGoAway = true
      else
        $.getJSON(window.MapList[this.selection][0], (data) ->
          window.selectedMap = data
          Crafty.scene('PlayGame')
        )
    if e.keyCode == Crafty.keys.Q
      this.selection-=1
      if this.selection == -1
        this.selection = window.MapList.length
        Crafty('spr_selectarrow, spr_space').each(() ->
          this.attr('y', this._y + 48 * (window.MapList.length + 1))
        )
      this.text(if this.selection < window.MapList.length then window.MapList[this.selection][1] else "Load Map...")
      Crafty('spr_selectarrow, spr_space').each(() ->
        this.attr('y', this._y - 48)
      )
    if e.keyCode == Crafty.keys.P
      this.selection+=1
      if this.selection == window.MapList.length + 1
        this.selection = 0
        Crafty('spr_selectarrow, spr_space').each(() ->
          this.attr('y', this._y - 48 * (window.MapList.length + 1))
        )
      this.text(if this.selection < window.MapList.length then window.MapList[this.selection][1] else "Load Map...")
      Crafty('spr_selectarrow, spr_space').each(() ->
        this.attr('y', this._y + 48)
      )
  ).bind('EnterFrame', () ->
    if Crafty('spr_selectarrow').y > 284
      Crafty('spr_selectarrow, spr_space, spr_selectstn, spr_selectline, aaa').each(() ->
        this.y -= 6;
      )
    else if Crafty('spr_selectarrow').y < 140 + Math.min(96, this.selection * 48)
      Crafty('spr_selectarrow, spr_space, spr_selectstn, spr_selectline, aaa').each(() ->
        this.y += 6;
      )
  )
  
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 230, y: 430})
  Crafty.e('2D, Canvas, spr_keyp').attr({x: 338, y: 430})
  Crafty.e('2D, Canvas, spr_arrowr').attr({x: 230, y: 480})
  Crafty.e('2D, Canvas, spr_arrowl').attr({x: 338, y: 480})
)

Crafty.scene('SelectMode', () ->
  Crafty.e('TitleText').attr({y: 218}).text('Select a mode:')
  Crafty.e('2D, Canvas, spr_keyq').attr({x: 194, y: 270})
  Crafty.e('2D, DOM, Text').attr({x: 153, y: 318, w: 200}).text('One Player').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, Canvas, spr_keyp, nobots').attr({x: 375, y: 270})
  Crafty.e('2D, DOM, Text, nobots').attr({x: 327, y: 318, w: 200}).text('Two Pl').textFont({size: '26px', family: 'Aller'}).textColor('#E23228')
  Crafty.e('2D, DOM, Text, nobots').attr({x: 407, y: 318, w: 200}).text('ayers').textFont({size: '26px', family: 'Aller'}).textColor('#4956FF')

  Crafty.e('2D, Keyboard').bind('KeyDown', (e) ->
    if e.keyCode == Crafty.keys.P
      Crafty.scene('SelectMap')
    if e.keyCode == Crafty.keys.Q
      Crafty("nobots").destroy()
      window.singlePlayerMode = true
      Crafty.scene('SelectMap')
  )
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

Crafty.scene('GameOver', () ->
  Crafty.e('GameOverText');
)
