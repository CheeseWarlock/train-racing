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
		Crafty.e("TrackSection").attr('dir', ['n','e']).at(0,1);
		Crafty.e("TrackSection").attr('dir', ['e','w']).at(1,1);
	},
	teardown: function() {
		Crafty("TrackSection").destroy();
	}
});

test("Track setup", function() {
  equal(Crafty("TrackSection").length, 3, "Track sections created");
  var track = Util.trackAt(0,0);
  deepEqual(track.dir, ['n','s'], "Tracks findable");
});

test("Basic train test", function() {
  var train = Crafty.e("PlayerTrain").at(0,0).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  train._moveAlongTrack(14);
  equal(train.y, 14, "Train moving properly in straight lines");
  train._moveAlongTrack(24);
  notEqual(train.y, 38, "Train is curving");
  train._moveAlongTrack(10);
  equal(train.y, 28, "Train completes curves");
});

test("Fast train test", function() {
  var train = Crafty.e("PlayerTrain").at(0,0).attr('sourceDirection', 's')
    .attr('targetDirection', 's').findTrack();
  train._moveAlongTrack(15);
    approx(train.x, 0, 0.1, "Train starts curve properly in x");
    notEqual(train.x, 0, "Train curves properly in x");
    approx(train.y, 14, 1, "Train starts curve properly in y");
  train._moveAlongTrack(20.5);
  approx(train.x, 14, 1, "Train follows curve properly in x");
  notEqual(train.y, 28, "Train is still curving in y");
  approx(train.y, 28, 0.1, "Train follows curve properly in y");
});

