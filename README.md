Quick and easy Ruby apps
=======================

*Require Highline gem.*

These short apps will provide the game logic for a musical tile game that I'm working on just for fun.

Is this a chord?
----------------

This is a short and simple program that prints out the interval-class prime form and type of chord, if any, of a given set of pitch-classes inputted by the user in duodecimal form.

Further coding to do:
* check that pitches aren't repeated
* check that only three or four pitches are given
* return an error for non-duodecimal input

Placement of tiles
------------------

There are 66 dyadminos total. These methods use arrays of hashes to keep track of which dyadminos are on the player's rack, on the gameboard, or still in the pile. They also allow the player to flip and swap the dyadminos on her rack, replace them for others in the pile, or place them on the gameboard.

Further coding to do:
* combine dyadmino-placement methods with chord-identifying methods so that only legal chords are allowed to be played on the board.
* calculate score of chords played.
* turn into hex board

Dyadminos!
==========

A musical tile game
-------------------

*Note:* After tinkering around with the Gosu gem, I've decided it would be more productive to dive straight into the RubyMotion toolkit instead. Since it will take me a while to get up to speed with RubyMotion, I'm just going to get all the game logic done first, then come back to programming the interface.

*Requires Gosu gem. Run main.rb in console.*

Basically, it's like Scrabble except with musical chords instead of words, and the playing pieces will resemble dominos with a different musical note on each face.

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
