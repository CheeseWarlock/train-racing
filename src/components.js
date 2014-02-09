Crafty.c('Grid', {
	init: function() {
		this.attr({
			w: Game.map_grid.tile.width,
			h: Game.map_grid.tile.height
		});
	},
	
	at: function(x, y) {
		if (x === undefined && y === undefined) {
			return {x: this.x / Game.map_grid.tile.width, y: this.y / Game.map_grid.tile.height};
		} else {
			this.attr({x: x * Game.map_grid.tile.width, y: y * Game.map_grid.tile.height});
			return this;
		}
	}
});

Crafty.c('Actor', {
	init: function() {
		this.requires('2D, Canvas, Grid');
	}
});

/**
 * Train: moves along track, contains movement logic.
 */
Crafty.c('Train', {
	init: function() {
		this.requires('Actor, Keyboard');
		this.speed = Constants.FULL_SPEED;
		this.playerOne = false;
		this.angle = 0;
		this.userCurve = false;
		this.canCurve = true;
		this.isCurving = false;
		this.progress = 0;
		this.followers = []; // following train cars
	},
	
	checkCollision: function() {
		// Not using Crafty's collision detection because bounding circles are what's needed
		// Inefficient (compares every combination twice), but everything is fast for small n
		var other = this;
		var min = 10000;
		
		Crafty("Train").each(function() {
			if (this.playerOne != other.playerOne) {
				if (Math.sqrt(((other.x - this.x) * (other.x - this.x))) + Math.sqrt(((other.y - this.y) * (other.y - this.y))) < 22) {
					Util.gameOver(true);
				}
			}
		});
	},
	
	findTrack: function() {
		var currentTrack;
		currentTrack = Util.trackAt(this.at().x, this.at().y);
		this.currentTrack = currentTrack;
		this.angle = Util.endAngle(currentTrack.dir[1]);
		return this;
	},
	
	_finishSection: function(dir) {
		this.angle = Util.endAngle(dir);
		this.x = this.currentTrack.x + Util.dirx(dir) * 14;
		this.y = this.currentTrack.y + Util.diry(dir) * 14;
		this.lastDir = this.nextDir;
		this._updateCurrentTrack(dir);
	},
	
	_hasStraightOption: function() {
		return (this.currentTrack.dir.indexOf(this.lastDir) > -1);
	},
	
	_hasCurveOption: function() {
		return (this.currentTrack.dir.length == 3 && (this.currentTrack.dir.indexOf(Util.opposite(this.lastDir)) > 0) ||
		this.currentTrack.dir.length == 2 && this.currentTrack.dir.indexOf(this.lastDir) == -1);
	},
	
	_moveAlongTrack: function(dist) { 
		this.remainingDist = dist;
		var remainingTries = 5;
		
		this._removeSpriteComponent();
		this._addSpriteComponent();
		while (this.remainingDist > 0 && remainingTries-- > 0) {
			if (this.isCurving) {
				this._moveCurved();
			} else {
				this._moveStraight();
			}
		}
		if (this.lightLayer) this.lightLayer.attr({x: this.x, y: this.y});
	},
	
	_moveStraight: function() {
		this.curveTo = null;
		// Straight
		this.progress = Util.dirx(this.lastDir) * (this.x - this.currentTrack.x) + Util.diry(this.lastDir) * (this.y - this.currentTrack.y);
		if (this.progress < Constants.TILE_HALF - this.remainingDist) {
			// Move full distance
			this.move(this.lastDir, this.remainingDist);
			this.remainingDist = 0;
		} else {
			// Snap and recalc
			this._finishSection(this.lastDir);
			this.remainingDist -= (Constants.TILE_HALF - this.progress);
			this.progress = 0;
		}
	},
	
	_moveCurved: function() {
		// Curved
		this.curveTo = Util.getTargetDirection(this.currentTrack, this.lastDir);
		var angularDiff = 1 / 28 * this.remainingDist * ((['en', 'nw', 'ws', 'se'].indexOf(this.lastDir + this.curveTo) > -1) ? -1 : 1);
		
		if (this.progress < Constants.CURVE_QUARTER - this.remainingDist) {
			// Move full distance
			this.angle += angularDiff;
			this.x += Math.cos(this.angle) * this.remainingDist;
			this.y += Math.sin(this.angle) * this.remainingDist;
			this.progress += this.remainingDist;
			this.angle += angularDiff;
			this.remainingDist = 0;
		} else {
			// Snap and recalc
			this._finishSection(this.curveTo);
			this.remainingDist -= (Constants.CURVE_QUARTER - this.progress);
			this.progress = 0;
		}
		this.nextDir = this.curveTo;
	}
});


/**
 * PlayerTrain: a train controlled by a player.
 */
Crafty.c('PlayerTrain', {
	init: function() {
		this.requires('Train');
		this.lastDir = 'n';
		this.passengers = 0;
		this.delivered = 0;
		this.lightLayer = Crafty.e('2D, Canvas, LightLayer').attr({z: 11});
		this.bind('EnterFrame', function() {
			var nextDirection = Util.getTargetDirection(this.currentTrack, this.lastDir);
			if (nextDirection == 's') {
				this.attr('z',3);
				this.followers[0].attr('z',2);
				this.followers[1].attr('z',1);
			} else if (nextDirection == 'n') {
				this.attr('z',1);
				this.followers[0].attr('z',2);
				this.followers[1].attr('z',3);
			}
		});
	},
	
	_addSpriteComponent: function(dir) {
		this.addComponent('spr_' + (this.playerOne?'r':'b') + 'train' + (this.curveTo && this.progress > 28 * Math.PI / 8 ? this.curveTo : this.lastDir));
		this.lightLayer.addComponent('spr_' + (this.playerOne?'r':'b') + 'train' + (this.curveTo && this.progress > 28 * Math.PI / 8 ? this.curveTo : this.lastDir) + 'light');
	},
	
	_removeSpriteComponent: function() {
		var baseSpriteName = 'spr_' + (this.playerOne?'r':'b') + 'train';
		for (var i in Constants.DIR_PREFIXES) {
			this.removeComponent(baseSpriteName + Constants.DIR_PREFIXES[i], false);
			this.lightLayer.removeComponent(baseSpriteName + Constants.DIR_PREFIXES[i] + 'light', false);
		}
	},
	
	_setBraking: function(braking) {
		if (braking) {
			if (!this.arrow) {
				this.arrow = Crafty.e('DirectionArrow').attr({x: this.x, y: this.y-30}).attr({target: this});
			}
		} else {
			if (this.arrow) {
				this.arrow.destroy();
				this.arrow = null;
			}
		}
		this.userCurve = braking;
		var playerOne = this.playerOne;
		Crafty("Train").each(function() {
			if (this.playerOne == playerOne) {
				this.speed = (braking? Constants.REDUCED_SPEED : Constants.FULL_SPEED);
			}
		});
	},
	
	bindKeyboardTurn: function(keyCode) {
		if (keyCode == null) {
			this.bind("EnterFrame", function() {

				if (this.speed == Constants.REDUCED_SPEED) {
					if (Math.random() > 0.925) {
						this._setBraking(false);
					}
				} else {
					if (Math.random() > 0.94) {
						this._setBraking(true);
					}
				}
			});
		} else {
			this.bind("KeyDown", function(e) {
				return function(e) {
					if (e.keyCode == keyCode) {
						this._setBraking(true);
					}
				};
			}(keyCode));
		}
		
		this.bind("KeyUp", function(e) {
			return function(e) {
				if (e.keyCode == keyCode) {
					this._setBraking(false);
				}
			};
		}(keyCode));
		return this;
	},
	
	_arriveAtStation: function() {
		if (this.currentTrack.station) {
			this.currentTrack.station.exchangePassengers(this);
		}
	},
	
	_updateCurrentTrack: function(dir) {
		this.currentTrack = Util.trackAt(this.currentTrack.at().x + Util.dirx(dir), this.currentTrack.at().y + Util.diry(dir));
		this._arriveAtStation();
		this.canCurve = this.userCurve;
		this.isCurving = (this._hasCurveOption() && this._hasStraightOption() ? this.userCurve : this._hasCurveOption());
		if (this._hasCurveOption() && this._hasStraightOption()) {
			this.followers[0].curves.push(this.isCurving);
			this.followers[1].curves.push(this.isCurving);
		}
	}
});

Crafty.c('FollowTrain', {
	init: function() {
		this.requires('Actor, Train');
		this.canCurve = false;
		this.curves = [];
		this.lightLayer = Crafty.e('2D, Canvas, LightLayer').attr({z: 11});
		
	},
	
	_addSpriteComponent: function() {
		var dir = (this.curveTo && this.progress > 28 * Math.PI / 8 ? this.curveTo : this.lastDir);
		this.addComponent('spr_' + (this.playerOne?'r':'b') + 'train' + (dir == 'n' || dir == 's'? 'side':''));
		this.lightLayer.addComponent('spr_' + (this.playerOne?'r':'b') + 'train' + (dir == 'n' || dir == 's'? 'side':'') + 'light');
		this.attr({x: this.x + 1});
		this.attr({x: this.x - 1});
	},
	
	_removeSpriteComponent: function() {
		var baseSpriteName = 'spr_' + (this.playerOne?'r':'b') + 'train';
		this.removeComponent(baseSpriteName, false).removeComponent(baseSpriteName + 'side', false);
		this.lightLayer.removeComponent(baseSpriteName + 'light', false).removeComponent(baseSpriteName + 'sidelight', false);
		this.attr({x: this.x + 1});
		this.attr({x: this.x - 1});
	},
	
	_arriveAtStation: function() {

	},
	
	_updateCurrentTrack: function(dir) {
		this.currentTrack = Util.trackAt(this.currentTrack.at().x + Util.dirx(dir), this.currentTrack.at().y + Util.diry(dir));
		this._arriveAtStation();
		this.canCurve = this.userCurve;
		if (this._hasCurveOption() && this._hasStraightOption()) {
			this.userCurve = (this.curves.shift() || false);
		}
		this.isCurving = (this._hasCurveOption() && this._hasStraightOption() ? this.userCurve : this._hasCurveOption());
	}
});

/**
 * Track section: a 1x1 piece of track with two or more dirs.
 */
Crafty.c('TrackSection', {
	init: function() {
		this.requires('Actor');
	},
	
	isStraight: function(dir) {
		return (
			this.dir.indexOf('s') > -1 && this.dir.indexOf('n') > -1 && (dir == 'n' || dir == 's')
			|| 
			this.dir.indexOf('e') > -1 && this.dir.indexOf('w') > -1 && (dir == 'e' || dir == 'w')
		);
	},
	
	associateStation: function(station) {
		this.station = station;
	}
});


/**
 * Station: associated with a track, has passenger values.
 */
Crafty.c('Station', {
	init: function() {
		this.population = 0;
		this.dropoffP1 = 0;
		this.dropoffP2 = 0;
		this.popular = false;
		this.popularCooldown = 500;
		this.requires('Actor, Mouse');
		this.bind('EnterFrame', function() {
			if (GameState.running) {
				this.populate();
			}
		});	
	},
	
	setup: function(x, y, dir) {
		this.at(x, y);
		this.setupAttach(dir);
	},
	
	setupAttach: function(dir) {
		var x = this.at().x;
		var y = this.at().y;
		this.facing = dir;
		if (dir == 's') {
			this.attachToTrack(x, y+1).attachToTrack(x+1, y+1);
		} else {
			this.attachToTrack(x+Util.dirx(dir), y).attachToTrack(x+Util.dirx(dir), y+1);
		}
		this.setupText();
	},
	
	setupText: function() {
		this.t = [];
		
		this.previousWaiting = 0;
		
		this.updateSprites();
	},
	
	populate: function() {
		if (!this.numStations) {
			this.numStations = Crafty('Station').length;
		}
		if (Math.random() > ((this.popular? 0.917: 0.947) + 0.005 * this.numStations)) {
			this.population += 1;
			this.updateSprites();
		}
		if (this.popularCooldown > 0) this.popularCooldown--;
		if (Math.random() > (this.popular?0.96:0.9991) && this.popularCooldown == 0 && false) {
			var letter = this.letter;
			this.popular = !this.popular;
			var popular = this.popular;
			this.popularCooldown = (this.popular?700:1400);
			Crafty('spr_' + (this.popular?'':'p') + 'stop' + this.letter).each(function() {
				this.removeComponent('spr_' + (popular?'':'p') + 'stop' + letter, false);
				this.addComponent('spr_' + (popular?'p':'') + 'stop' + letter);
			});
		}
	},
	
	attachToTrack: function(x, y) {
		Util.trackAt(x, y).associateStation(this);
		return this;
	},
	
	// There be magic numbers ahead
	exchangePassengers: function(train) {
		train.passengers -= (train.playerOne? this.dropoffP1 : this.dropoffP2);
		train.delivered += (train.playerOne? this.dropoffP1 : this.dropoffP2);
		train.playerOne? this.dropoffP1 = 0 : this.dropoffP2 = 0;
		
		var room = 100 - train.passengers;
		var overflow = this.population - room; // number that will be left waiting
		
		var pickup = (overflow > 0? 100 - train.passengers: this.population);
		train.passengers += pickup;
		var currentStation = this;
		var targetCount = Crafty("Station").length;
		var playerOne = train.playerOne;
		
		while (pickup > 0) {
			var target = Crafty(Crafty("Station")[Math.floor(Math.random() * targetCount)]);
			if (target != currentStation) {
				playerOne? target.dropoffP1++: target.dropoffP2++;
				pickup--;
			}
		}
		this.population = (overflow > 0? overflow: 0);
		Crafty("Station").each(function() {
			this.updateSprites();
		});
		Crafty("PlayerScore").each(function() {
			if (this.train) {
				var x = [];
				var p = this.playerOne;
				Crafty("Station").each(function() {
					var t = (p?this.dropoffP1: this.dropoffP2);
					if (t > 1) x.push([t,this.letter,this.popular]);
				});
				x.sort(function(a,b){return b[0]-a[0];});
				this.bar.update(this.train.passengers, x);
			}
		});
	},
	
	updateSprites: function() {
		if (this.population / 12.0 == this.t.length + 1) {
			var remaining = Math.min(this.population, 72) - (this.t.length) * 12;
			var pos = this.t.length;
			if (this.facing == 'w') {
				var x = this._x + 6 * (pos % 2);
				var y = this._y + 2 + 8 * pos;
			} else if (this.facing == 'e') {
				var x = this._x + 20 - 6 * (pos % 2);
				var y = this._y + 2 + 8 * pos;
			} else {
				var x = this._x + 2 + 8 * pos;
				var y = this._y + 12 + 4 * (pos % 2);
			}
			while (remaining >= 12) {
				this.t.push(Crafty.e('StationPerson').attr(
					{"x" : x, "y": y}
				).fadeIn(this.facing));
				remaining -= 12;
				pos++;
			}
		} else {
			while (this.t.length > this.population / 12) {
				this.t[this.t.length - 1].fadeOut();
				this.t.splice(this.t.length - 1,1);
			}
		}
		return this;
	}
});

/**
 * 
 */
Crafty.c('StationPerson', {
	init: function() {
		this.requires('2D, Canvas, spr_person00');
	},
	
	fadeIn: function(dir) {
		this.alpha = 0;
		this.x -= Util.dirx(dir) * 10;
		this.y -= Util.diry(dir) * 10;
		for (var i=0;i<=9;i++) {
			setTimeout(function(o, dir) {
				return function() {
					o.attr({alpha: o.alpha + 0.1, x: o.x + Util.dirx(dir), y: o.y + Util.diry(dir)});
				};
			}(this, dir), i * 50);
		}
		return this;
	},
	
	fadeOut: function() {
		var delay = Math.random() * 300;
		for (var i=0;i<=9;i++) {
			setTimeout(function(o) {
				return function() {
					o.attr({alpha: o.alpha - 0.1, y: o._y - 3 * (o.alpha - 0.6)});
					if (o.alpha < 0.1) o.destroy();
				};
			}(this), i*50 + delay);
		}
		return this;
	}
});

Crafty.c('PlayerScore', {
	init: function() {
		this.requires('2D, DOM, Text').textFont({size: '20px', family: 'Aller'});
		this.display = 0;
		this.attr({h: 47, w: 270});
		this.css({"padding": 5, "backgroundColor": "none", "margin": 10});
		
		this.bind('EnterFrame', function() {
			if (this.display != this.train.passengers) {
				(this.display > this.train.passengers ? this.display-- : this.display++); 
			}
			this.text(this.display + "% Full");
		});
	},
	
	setup: function() {
		this.bar = Crafty.e('BarController').attr({x: this.x + 10, y: this.y}).attr({playerOne: this.playerOne}).setup().update();
		this.attr({z: 0});
	}
});

Crafty.c('DirectionArrow', {
	init: function() {
		this.requires('Actor, spr_arrowsign, Mouse')
		    .attr({z: 1000})
		    .bind('EnterFrame', function() {
			if (GameState.running) {
				this.x = this.target.x;
				this.y = this.target.y - 30;
			}
		});
	}
});

Crafty.c('Dialog', {
	init: function() {
		this.requires('2D, DOM, Text')
		    .css({backgroundColor: '#2B281D', textAlign: 'center', border: '4px solid #FFFDE8'})
		    .textFont({size: '30px', family: 'Aller'})
		    .textColor('#FFFDE8');
	}
});

Crafty.c('ClockController', {
	init: function() {
		this.requires('Dialog').attr({x: 234, y: 500, w: 140, h: 40}).textColor('#84FFEC').css({border: '4px solid #606060'});
		GameClock.newDay();
		this.text(GameClock.hour + (GameClock.minute > 9? ":":":0")+ GameClock.minute);
		this.tickDelay = 0;
		this.bind('EnterFrame', function() {
			percentTimePassed = (GameClock.hour - 6) / 4 + (GameClock.minute / 240);
			if (GameState.running && this.tickDelay++ > 22) {
				GameClock.update();
				this.text(GameClock.hour + (GameClock.minute > 9? ":":":0")+ + GameClock.minute);
				this.tickDelay = 0;
				if (GameClock.hour == 10) {
					Util.gameOver(false);
				}
			}
			Crafty('AmbientLayer').each(function() {
				this.color(Util.sunrise(percentTimePassed));
			});
			Crafty('LightLayer').each(function() {
				this.attr('alpha', 1 - percentTimePassed);
			});
		});
		setTimeout(function() {
			GameState.running = true;
		}, 1000);
	}
});

/**
 * Controls train movement. Makes sure all trains move before checking collision.
 */
Crafty.c('TrainController', {
	init: function() {
		this.bind('EnterFrame', function() {
			if (GameState.running) {
				Crafty('Train').each(function() {
					this._moveAlongTrack(this.speed);
				});
				Crafty('Train').each(function() {
					this.checkCollision();
				});
			}
		});
	}
});

Crafty.c('EndingText', {
	init: function() {
		this.requires('Dialog').textFont({size: '20px'});
		this.display = 0;
		this.attr({x: 0, y: 112, w: 268, h: 130});
		this.css({
			padding: 20, 
			margin: '0px 150px', 
			width: 600,
			height: 200,
			boxShadow: '-8px 8px 0px rgba(0,0,0,0.4)'
		});
		this.bind("KeyDown", function(e) {
			if (e.keyCode == Crafty.keys.SPACE) {
				Crafty('TrainController').destroy(); // Because of the 2D issue
				Crafty.scene('PlayGame');
			}
		});
		Crafty.e('2D, DOM, spr_space').attr({x:this.x + 260, y:this.y + 152});
	}
});

Crafty.c('VictoryText', {
	init: function() {
		this.requires('EndingText');
		
		var p1score = 0;
		var p2score = 0;
		
		Crafty('PlayerTrain').each(function() {
			if (this.playerOne) {
				p1score = this.delivered;
			} else {
				p2score = this.delivered;
			}
		});
		
		if (p1score != p2score) {
			this.css({border: '4px solid #' + (p1score > p2score ? 'E23228' : '4956FF'),
					  borderTop: '4px solid #' + (p1score > p2score ? 'FF817C' : '848EFF'),
					  borderBottom: '4px solid #' + (p1score > p2score ? 'B71607' : '1E2DCE')});
		}
		this.text('The morning rush is over!<br/>Passengers delivered:<br/>Red: ' + p1score + ', Blue: ' + p2score+'<br/>' + 
		(p1score == p2score? 'It\'s a Draw!':((p1score > p2score? 'Red':'Blue') + ' Line wins!')) + '<br/>Total deliveries: ' + (p1score + p2score));
	}
});

Crafty.c('FailureText', {
	init: function() {
		this.requires('EndingText');
		this.text(
			Constants.ENDING_DIALOGS[0][Math.floor(Math.random() * Constants.ENDING_DIALOGS[0].length)] + "<br/>" +
			Constants.ENDING_DIALOGS[1][Math.floor(Math.random() * Constants.ENDING_DIALOGS[1].length)]);
	}
});

Crafty.c('BarController', {
	init: function() {
		this.requires('2D, Canvas').attr({z: 15});
	},
	
	setup: function() {
		this.attr({h: 20, w: 20});
		var c = (this.playerOne? 'r':'b');
		Crafty.e('2D, Canvas, spr_barback').attr({x: this.x, y: this.y, z: 15});
		this.l = Crafty.e('2D, Canvas, spr_' + c + 'barl').attr({x: this.x, y: this.y, z: 15});
		this.b = Crafty.e('2D, Canvas, spr_' + c + 'bar').attr({w: 0, x: this.x + 4, y: this.y, z: 15});
		this.r = Crafty.e('2D, Canvas, spr_' + c + 'barr').attr({x: this.x + 4, y: this.y, z: 15});
		return this;
	},
	
	update: function(fullness, ticks) {
		this.attr({x: this.x, y: this.y, z: 15});
		this.l.attr({x: this.x, y: this.y, z: 15});
		this.b.attr({x: this.x + 4, w: (fullness > 4? fullness * 2 - 8:0), z: 15});
		this.r.attr({x: (fullness > 2 && ticks.length?this.x - 4 + fullness * 2:this.x+4), z: 15});
		for (var i in this.ticks) {
			this.ticks[i].destroy();
		}
		this.ticks = [];
		for (var i in this.stops) {
			this.stops[i].destroy();
		}
		this.stops = [];
		var d = -2;
		var previous = 0;
		for (var i in ticks) {
			if (ticks[i][0] > 0) {
				var attempt = this.x + d + ((ticks[i][0]|1)-1) - 6;
				while (i > 0 && attempt < previous + 12) attempt += 2;
				this.stops.push(Crafty.e('2D, Canvas, spr_' + (ticks[i][2]?'p':'')+ 'stop' + ticks[i][1]).attr({x: attempt, y: this.y - 22, z: 15}));
				previous = attempt;
			}
			if (i < ticks.length - 1) {
				d += ticks[i][0] * 2;
				this.ticks.push(Crafty.e('2D, Canvas, spr_' + (this.playerOne? 'r':'b') + 'bart').attr({x: this.x + d, y: this.y, z: 15}));
			}
		}
		return this;
	}
});

/**
 * A line of text to simplify the title screen.
 */
Crafty.c('TitleText', {
	init: function() {
		this.requires('2D, DOM, Text').attr({x: 0, w: 616}).css({textAlign: 'center'}).textFont({size: '17px', family: 'Aller'}).textColor('#FFFDE8');
	}
});
