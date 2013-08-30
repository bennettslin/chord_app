  def scanSurroundingSlots(lower_x, lower_y, higher_x, higher_y)
    #hex board will have five directions to check
    a = checkLegalSonority(lower_x, lower_y, 0) # check vertical
    b = checkLegalSonority(lower_x, lower_y, 1) # check horizontal
    lower_x == higher_x ? axis_to_check = 1 : axis_to_check = 0
    c = checkLegalSonority(higher_x, higher_y, axis_to_check)
    # this is a hack; it might not work with a hex board
    puts a, b, c
  end

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
@filled_board_slots =  ["..........",
                        "..........",
                        "..1..45...",
                        "..4..6....",
                        "..24.25...",
                        "..576.2...",
                        "...3716...",
                        "....2.....",
                        "..........",
                        ".........."]

print "The method returns #{scanSurroundingSlots(3, 6, 4, 6)}."
