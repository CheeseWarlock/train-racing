Morning Commute
============

A two-player game with *exciting train-conducting action*! Each player controls one train, travelling between stations to pick up passengers and drop them off at their destinations. Made in a combination of Javascript and Coffeescript, using Crafty.js.

#Building
All files needed to run the game are included. When modifying the Coffeescript files, build them all into a single file using `coffee --join "application.js" --compile "."` rather than to individual .js files.

To edit levels, use [Tiled](http://mapeditor.org). Export maps to JSON, and edit `maps.json` to include name-location pairs to the maps list.
