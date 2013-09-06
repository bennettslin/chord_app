Dyadminos! A Musical Tile Game
==============================

This is a musical tile game that I'm working on just for fun. Basically, it's like Scrabble except with musical chords instead of words, and the playing pieces will resemble dominos with a different musical note on each face.

Is this a chord?
----------------

*Require Highline gem.*

This is a quick and easy app that just prints out the interval-class prime form and type of chord, if any, of a given set of pitch-classes based on user input.

The game logic
--------------

*Requires Highline gem. Run begin.rb in console.*

This app will provide the game logic. Each dyadmino is like a domino with a different musical note on each face. This app generates the pile, then keeps track of which dyadminos are on the player's rack, on the gameboard, or still in the pile. The player may flip or swap the dyadminos on her rack, replace one for another in the pile, or else place one on the gameboard. The app will determine whether her move is legal. She is free to form complete chords which score points, or incomplete chords which score no points. She cannot place one dyadmino over one already on the board or repeat a note in the same row.

Further coding to do:
* calculate score of chords played
* allow legal movement of any dyadmino already on board
* turn into hexagonal board
* allow for two players

The interface
-------------

*Requires Gosu gem. Run main.rb in console.*

*Note:* After tinkering around with the Gosu gem, I've decided it would be more productive to dive straight into the RubyMotion toolkit instead. So I'm going to work on finishing the game logic and hold off on programming the interface for now. I'm leaving this here for anyone who's interested.

Nomenclature
------------

* "space" is a single space on board, "monotile" is single piece, "dyadmino" is full piece
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
