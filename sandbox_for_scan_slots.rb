  # code is kept simple so as not to confuse me when I add a third axis for the hex board
  def scanSurroundingSlots(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
    # only checks if dyadmino placement is illegal for physical reasons:
    # repeated pcs, more than the maximum allowed in a row, and semitones under folk or rock rules
    case @rule
      when (0..4) ; max_card = 4
      when 5; max_card = 8
      when 6; max_card = 6
    end
    array_of_sonorities = Array.new
    # each array is pc, x, y, axis to check
    directions_to_check = [[lower_pc, lower_x, lower_y, "ver"], [lower_pc, lower_x, lower_y, "hor"],
                            [higher_pc, higher_x, higher_y, ""]]
    if lower_x == higher_x # doesn't check parallel axis twice
      directions_to_check[2][3] = "hor"
    elsif lower_y == higher_y
      directions_to_check[2][3] = "ver" # on hex board there will be five directions
    end
    # lower_vertical, lower_horizontal, higher_vertical, higher_horizontal
    directions_to_check.each do |origin|
      temp_sonority = [origin[0]]
      [-1, 1].each do |vector| # checks in both directions
        temp_pc, temp_x, temp_y = "", origin[1], origin[2]
        while temp_pc != "."
          # establishes that the pc in the temporary container is NOT the empty slot
          # where the dyadmino might go
          if origin[3] == "ver" # checking vertically
            temp_y = (temp_y + vector) % @board_size
          elsif origin[3] == "hor" # checking horizontally; on hex board, there will be a third condition
            temp_x = (temp_x + vector) % @board_size
          end
          if temp_x == lower_x && temp_y == lower_y
            temp_pc = lower_pc
          elsif temp_x == higher_x && temp_y == higher_y
            temp_pc = higher_pc
          else
            temp_pc = @filled_board_slots[temp_y][temp_x]
          end
          if temp_sonority.count > max_card
            return :illegal_maxed_out_row
          elsif temp_sonority.include?(temp_pc) && temp_pc != "."
            return :illegal_repeated_pcs
          elsif @rule < 3 # ensures there are no semitones when playing by folk and rock rules
            [-1, 1].each do |j|
              if temp_sonority.include?(((temp_pc.to_i(12) + j) % 12).to_s(12)) && temp_pc != "."
                return :illegal_semitones
              end
            end
          end
          if temp_pc != "."
            vector == -1 ? temp_sonority.unshift(temp_pc) :
            temp_sonority.push(temp_pc)
          end
        end
      end
      array_of_sonorities << temp_sonority.sort!.join
    end
    return array_of_sonorities
  end


@rule = 1
@board_size = 5
@filled_board_slots =  ["..b..",
                        ".a.71",
                        "...2.",
                        "..1..",
                        "....."]

print "The method returns #{scanSurroundingSlots("3", 2, 1, "5", 2, 2)}."
