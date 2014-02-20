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
  Crafty("TrackSection").each(function() {
  	console.log('this.at().x + ", " + this.at().y');
  });
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
  train._moveAlongTrack(35);
  equal(train.y, 28, "Train moving properly");
});

