Is This a Chord?
================

A quick and easy Ruby app
-------------------------

*Requires Highline gem.*

This is a short and simple program that prints out the interval-class prime form and type of chord, if any, of a given set of pitch-classes inputted by the user in duodecimal form.

Further coding to do:
* check that pitches aren't repeated
* check that only three or four pitches are given
* return an error for non-duodecimal input


Dyadminos!
==========

A musical tile game
-------------------

*Requires Gosu gem. Run main.rb in console.*

The above algorithm is really for a more complex game I'm working on for fun that will use the Gosu gem. Basically, it's like Scrabble except with musical chords instead of words, and the playing pieces will resemble dominos with a different musical note on each face.

I'm still figuring out how best to organise my classes and methods in separate files, so sorry if everything's a little scattered right now. Here is my personal schedule for what I need to get done.

Nomenclature
------------

* "empty_slot" is a single free space on board, "monotile" is single piece, "dyadmino" is full piece
* "rack" is the dyadminos currently in player's rack, "pile" is the rest
* "pc" is a note, "pair", "triplet", and "quadruplet" are ANY 2,3 and 4 pcs in a row, legal or not
* "dyad" and "inc_seventh" are LEGAL pairs and triplets that DON'T score
* "triad" and "seventh" are LEGAL triplets and quadruplets that DO score
* "dichord", "trichord", and "tetrachord" will be for post-tonal games (these must be separate algorithms, as they will allow inverses)

Updates and draws
-----------------

* Change all monotiles to center orientation
* Draw monotile pcs 45 x 90
* Create steelpan wav files
* play sounds when ANY click on solid monotile
* Keyboard input moves map

Data and algorithms
-------------------

* Create table of gameboard, 15 x 15 array, each defined by pc number and whether slot or monotile
* Create array of 66 dyadminos, array of those in player's rack, array of those on gameboard
* Create array to push in chords already played on gameboard
* Create algorithms to check for dyads and incomplete sevenths

Player inputs
-------------

* First click on dyadmino in footer selects it
* The next click flips it upside-down
* Click on empty slot in gameboard establishes it as place for first monotile
* Check if it's illegal; if so, nothing happens
* If it's legal, faint first monotile shows in that slot, and legal slots flash for faint second monotile
* Any click outside flashing slots cancels whole operation
* Finish chord and calculate score

To do in the future
-------------------

* allow player to switch between tonal and post-tonal notation
* allow player to scroll screen
* allow any dyadminos on board to be moved
* allow for multiple players
* make new version with hexagonal board and pieces
* recode for mobile interface (use RubyMotion?)
