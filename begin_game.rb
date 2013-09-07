require "highline/import"

require_relative "tiles_state"

# rules are 0:folk, 1:rock, 2:rock with classical, 3: jazz, 4:jazz with classical
# 5:octatonic, 6:hexatonic and whole-tone (post-tonal rules include inversions)


ask_rule = ask("Play by what rules? 0:folk, 1:rock, 2:rock with classical, 3: jazz\n4:jazz with classical, 5:octatonic, 6:hexatonic and whole-tone")
ask_init = ask("Enter number as sample size to test probability, or anything else to play game.")
# legal chords array is stored in game_tiles instance
# so that they're only called once per game match
game_tiles = TilesState.new(ask_rule.to_i)
# print game_tiles.checkLegalChord("047")


if ask_init.to_i > 6
  game_tiles.testing
  game_tiles.testSonorityProbability(ask_init.to_i)
else # play by rules
  rule = ask_init.to_i
  loop do
    puts "*" * 72
    ask_slot = ask("Enter slot number to perform action on, or 'm' for a random legal move.\n(or 'b' for board, 'r' for rack, 'p' for pile, or 'q' to quit)")
    if ask_slot[0] == "q"
      break
    elsif ask_slot[0] == "m"
      game_tiles.testing
      print "There is no legal move to be made.\n" if !game_tiles.playRandomLegalChord
    elsif ask_slot[0] == "b"
      game_tiles.showBoard
    elsif ask_slot[0] == "p"
      game_tiles.showPile
    elsif ask_slot[0] == "r"
      game_tiles.showRack
    elsif
      slot_num = ask_slot[0].to_i
      if slot_num.to_i.class == Fixnum
        ask_action = ask("Choose 'f' to flip, 'r' to replace, 'p' to play\nor second slot number to swap.")
        if ask_action[0] == "f"
          game_tiles.flipDyadmino(slot_num)
        elsif ask_action[0] == "r"
          game_tiles.replaceDyadmino(slot_num)
        elsif ask_action[0] == "p"
          ask_top_x = ask("x-coordinate of top pc:")
          ask_top_y = ask("y-coordinate of top pc:")
          ask_board_orient = ask("orientation (0 through 5):")
          game_tiles.playDyadmino(slot_num, ask_top_x.to_i(36), ask_top_y.to_i(36), ask_board_orient.to_i)
          # game program ALWAYS orients each dyadmino based on lower and higher pcs
          # however, player's understanding of orientation is based on top and bottom pcs
        else
          slot_swap = ask_action[0].to_i
          if slot_swap.to_i.class == Fixnum && slot_swap != slot_num
            game_tiles.swapDyadminos(slot_num, slot_swap)
          end
        end
      end
    end
  end
end
