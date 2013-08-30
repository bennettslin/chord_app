def checkLegalSonority(x, y, dyadmino_orient)
# ONLY checks if no repeated pcs or more than four in a row
  temp_sonority = [@filled_board_slots[y][x]]
  [-1, 1].each do |i| # checks in both directions
    temp_x, temp_y = x, y
    while @filled_board_slots[temp_y][temp_x] != "."
      if dyadmino_orient == 0 # 0 = checking vertically
        (temp_y += i) % @board_size
      else # 1 = checking horizontally; on hex board, there will be a third condition
        (temp_x += i) % @board_size
      end
      if temp_sonority.count > 4 || temp_sonority.include?(@filled_board_slots[temp_y][temp_x])
        return false # repeats pcs or more than four in a row
      elsif
        @filled_board_slots[temp_y][temp_x] == "."
      else
        i == -1 ? temp_sonority.unshift(@filled_board_slots[temp_y][temp_x]) :
          temp_sonority.push(@filled_board_slots[temp_y][temp_x])
      end
    end
  end
  return temp_sonority.join
end

@board_size = 10
@filled_board_slots =  ["123.....",
                        "..........",
                        "..4..45...",
                        "..4..6....",
                        "..24......",
                        "..576.5...",
                        "..........",
                        "..........",
                        "..........",
                        ".........."]

print "The method returns #{checkLegalSonority(1, 0, 1)}."
