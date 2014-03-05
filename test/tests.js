QUnit.extend( window, {

	approx: function(actual, expected, maxDifference, message) {
		var passes = (actual === expected) || Math.abs(actual - expected) <= maxDifference;
		QUnit.push(passes, actual, expected, message);
	},

	notApprox: function(actual, expected, minDifference, message) {
		QUnit.push(Math.abs(actual - expected) > minDifference, actual, expected, message);
	}
});

Crafty.init(100, 100, 'dummy-stage');
Crafty.background('#2B281D');

module("Placement and movement tests", {
	setup: function() {
		Crafty.e("TrackSection").attr('dir', ['n','s']).at(0,0);
		Crafty.e("TrackSection").attr('dir', ['n','s']).at(0,1);
		Crafty.e("TrackSection").attr('dir', ['n','e']).at(0,2);
		Crafty.e("TrackSection").attr('dir', ['e','w']).at(1,2);
		Crafty.e("TrackSection").attr('dir', ['n','w']).at(2,2);
		Crafty.e("TrackSection").attr('dir', ['n','s']).at(2,1);
		Crafty.e("TrackSection").attr('dir', ['n','s']).at(2,0);
	},
	teardown: function() {
		Crafty("TrackSection").destroy();
		Crafty("Train").destroy();
	}
});

test("Track setup", function() {
  equal(Crafty("TrackSection").length, 7, "Track sections created");
  var track = Util.trackAt(0,0);
  deepEqual(track.dir, ['n','s'], "Tracks findable");
});

test("Basic train test", function() {
  var train = Crafty.e("PlayerTrain").at(0,1).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  train.moveAlongTrack(14);
  equal(train.y, 14+28, "Train moving properly in straight lines");
  train.moveAlongTrack(24);
  notEqual(train.y, 38+28, "Train is curving");
  train.moveAlongTrack(10);
  equal(train.y, 28+28, "Train completes curves");
});

test("Fast train test", function() {
  var train = Crafty.e("PlayerTrain").at(0,1).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  train.moveAlongTrack(15);
    approx(train.x, 0, 0.1, "Train starts curve properly in x");
    notEqual(train.x, 0, "Train curves properly in x");
    approx(train.y, 14+28, 1, "Train starts curve properly in y");
  train.moveAlongTrack(20.5);
  approx(train.x, 14, 1, "Train follows curve properly in x");
  notEqual(train.y, 28+28, "Train is still curving in y");
  approx(train.y, 28+28, 0.1, "Train follows curve properly in y");
});

test("Train collision test", function() {
  var red = Crafty.e("PlayerTrain").at(0,1).attr('sourceDirection', 's')
    .attr('playerOne', true).attr('targetDirection', 's').findTrack();
  var blue = Crafty.e("PlayerTrain").at(2,1).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
    
  red.moveAlongTrack(37);
  blue.moveAlongTrack(37);
  equal(red.y, 28+28, "Train completes curves");
  equal(blue.y, 28+28, "Train completes curves");
  equal(red.checkCollision(), false, "Trains are not colliding yet");
  red.moveAlongTrack(20);
  equal(red.checkCollision(), true, "Trains collide after moving further");
});

test("Collision consistency test", function() {
  Math.seedrandom('some string');
  var red = Crafty.e("PlayerTrain").at(0,0).attr('sourceDirection', 's')
    .attr('playerOne', true).attr('targetDirection', 's').findTrack();
  red.moveAlongTrack(22.2);
  
  var blue = Crafty.e("PlayerTrain").at(0,0).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  
  var collisions = 0;
  
  blue.moveAlongTrack(0.1);
    var total, increase;
  for (var total = 0, increase = 0; total <= 30;
	function() {
	    increase = Math.random();
	    total += increase;
	}()) {
    red.moveAlongTrack(increase);
    blue.moveAlongTrack(increase);
    if (red.checkCollision()) collisions++;
    if (blue.checkCollision()) collisions++;
 }	
    
  equal(collisions, 0, "Trains never collide");
  
  
});

test("Reversing motion", function() {
  var train = Crafty.e("PlayerTrain").at(0,1).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  train.moveAlongTrack(1);
  train.moveAlongTrack(-1);
  equal(train.y, 28, "Trains can move backwards along straight tracks");
  train.moveAlongTrack(30);
  train.moveAlongTrack(-30);
  equal(train.y, 28, "Trains can move backwards along curved tracks");
  
});

