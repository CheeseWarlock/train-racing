Crafty.init(100, 100, 'dummy-stage');

test("Crafty.js setup", function() {
  ok(Crafty.e("Actor"), "Stage is accepting entities");
});

