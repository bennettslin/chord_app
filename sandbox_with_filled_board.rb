  def scanSurroundingSlots(lower_x, lower_y, higher_x, higher_y)
    # the two pcs share one axis, so there are three sonorities to check
    # hex board will have FIVE sonorities to check, use mod 3
    first_sonority = checkLegalSonority(lower_x, lower_y, 0) # check vertical
    second_sonority = checkLegalSonority(lower_x, lower_y, 1) # check horizontal
    lower_x == higher_x ? axis_to_check = 1 : axis_to_check = 0
    third_sonority = checkLegalSonority(higher_x, higher_y, axis_to_check)
    return first_sonority, second_sonority, third_sonority
  end

  def checkLegalSonority(x, y, axis_to_check)
  # ONLY checks if no repeated pcs or more than the maximum allowed in a row,
  # and no semitone dyads if playing by folk or rock rules
    case @rule
      when (0..4) ; max_card = 4
      when 5; max_card = 8
      when 6; max_card = 6
    end
    temp_sonority = [@filled_board_slots[y][x]]
    [-1, 1].each do |i| # checks in both directions
      temp_x, temp_y = x, y
      while @filled_board_slots[temp_y][temp_x] != "."
        if axis_to_check == 0 # 0 = checking vertically
          (temp_y += i) % @board_size
        else # 1 = checking horizontally; on hex board, there will be a third condition
          (temp_x += i) % @board_size
        end
        temp_pc = @filled_board_slots[temp_y][temp_x]
        if temp_sonority.count > max_card || temp_sonority.include?(temp_pc)
          return false # repeated pcs, or more than max
        elsif
          @filled_board_slots[temp_y][temp_x] == "."
        else
          if @rule < 3
            [-1, 1].each do |j|
              return false if temp_sonority.include?(((temp_pc.to_i(12) + j) % 12).to_s(12))
            end
          end
          i == -1 ? temp_sonority.unshift(@filled_board_slots[temp_y][temp_x]) :
            temp_sonority.push(@filled_board_slots[temp_y][temp_x])
        end
      end
    end
    return temp_sonority.join
  end

@rule = 2
@board_size = 10
@filled_board_slots =  ["..........",
                        "..........",
                        "..1..45...",
                        "..4..6....",
                        "..2.25...",
                        "..564.2...",
                        "...370a...",
                        "....2.....",
                        "..........",
                        ".........."]

print "The method returns #{scanSurroundingSlots(3, 6, 4, 6)}."
