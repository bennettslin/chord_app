require "highline/import"

require_relative "tiles_state"

ask_rule = ask("Play by what rules? 0:folk, 1:rock, 2:rock with classical, 3: jazz\n4:jazz with classical, 5:octatonic, 6:hexatonic and whole-tone")
game_tiles = TilesState.new(ask_rule.to_i)

ask_init = ask("Enter number as sample size to test probability.")
game_tiles.testing(2)
game_tiles.testSonorityProbability(ask_init.to_i)
