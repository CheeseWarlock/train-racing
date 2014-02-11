Morning Commute
============

A two-player game with *exciting train-conducting action*! Each player controls one train, travelling between stations to pick up passengers and drop them off at their destinations. Made in a combination of Javascript and Coffeescript, using Crafty.js.

###Playing the game

Hold down your key (P or Q) to reduce your speed. If your speed is reduced when you reach a junction,
you will turn; otherwise you will continue going straight. 

Moving past a station will drop off and pick up passengers from that station. Each passenger has a
destination station. The destinations of your passengers can be seen at the bottom of the screen, with
the first station representing the highest demand.

Trains have a limited capacity. If your train is full, you will need to drop off passengers before
picking up any more.

At 10:00 AM, the morning commute is over and the player who has delivered more passengers wins. If the
trains collide, neither player wins.

###Building
All files needed to run the game are included. When modifying the Coffeescript files, build them all into a single file using `coffee --join "src/application.js" --compile "src/"` (or a similar command) rather than to individual .js files.

To edit levels, use [Tiled](http://mapeditor.org). Export maps to JSON, and edit `src/maps.json` to add name-location pairs to the maps list.

#####Notes for map design
* All objects must be in the proper layer.
* Tracks must form complete circuits; dead ends may have unexpected results.
* Stations must be facing adjacent tracks.
* Train locations are marked by placing train heads in the 'Trains' layer.
* Trains must start on straight sections of track.
* Props should not overlap tracks.
