require "highline/import"

require_relative "tiles_state"

rule = 0 # rule will eventually be based on user input
# rules are 0:folk, 1:rock, 2:rock with classical, 3: jazz, 4:jazz with classical
# 5:octatonic, 6:hexatonic and whole-tone (post-tonal rules include inversions)

# legal chords array is stored in game_tiles instance so that they're only called once per game match
game_tiles = TilesState.new(rule)
# print game_tiles.checkLegalChord("047")

loop do
  puts "*" * 72
  ask_slot = ask("Enter slot number (0 through 5) to perform action:\n(or 'b' for board, 'r' for rack, 'p' for pile, or 'q' to quit)")
  if ask_slot[0].downcase == "q"
    break
  elsif ask_slot[0].downcase == "b"
    game_tiles.showBoard
  elsif ask_slot[0].downcase == "p"
    game_tiles.showPile
  elsif ask_slot[0].downcase == "r"
    game_tiles.showRack
  elsif
    slot_num = ask_slot[0].to_i
    if slot_num.between?(0, 5)
      ask_action = ask("Choose 'f' to flip, 'r' to replace, 'p' to play\nor second slot number to swap:")
      if ask_action[0].downcase == "f"
        game_tiles.flipDyadmino(slot_num)
      elsif ask_action[0].downcase == "r"
        game_tiles.replaceDyadmino(slot_num)
      elsif ask_action[0].downcase == "p"
        ask_top_x = ask("x-coordinate of top pc:")
        ask_top_y = ask("y-coordinate of top pc:")
        ask_board_orient = ask("orientation (0 through 3):")
        game_tiles.playDyadmino(slot_num, ask_top_x.to_i(36), ask_top_y.to_i(36), ask_board_orient.to_i)
        # game program ALWAYS orients each dyadmino based on lower and higher pcs
        # however, player's understanding of orientation is based on top and bottom pcs
      else
        slot_swap = ask_action[0].to_i
        if slot_swap.to_i.between?(0, 5) && slot_swap != slot_num
          game_tiles.swapDyadminos(slot_num, slot_swap)
        end
      end
    end
  end
end
