  def scanNeighboringSpaces(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
    # only checks if dyadmino placement is illegal for physical reasons:
    # repeated pcs, more than the maximum allowed in a row, and semitones under folk or rock rules
    case @rule
      when (0..4) ; max_card = 4
      when 5; max_card = 8
      when 6; max_card = 6
    end
    array_of_sonorities = Array.new
    pcs_to_check = [{ pc: lower_pc, x: lower_x, y: lower_y },
      { pc: higher_pc, x: higher_x, y: higher_y }]
    directions_to_check = [:eastwest, :se_to_nw, :sw_to_ne]
    if lower_y == higher_y # so that same direction of dyadmino orientation isn't checked twice
      parallel_axis = directions_to_check[0]
    elsif lower_x == higher_x
      parallel_axis = directions_to_check[1]
    else
      parallel_axis = directions_to_check[2]
    end
    pcs_to_check.each do |origin|
      directions_to_check.each do |dir|
        temp_sonority = [origin[:pc]]
        unless origin[:pc] == higher_pc && parallel_axis == dir
          [-1, 1].each do |vector| # checks in both directions
            temp_pc, temp_x, temp_y = String.new, origin[:x], origin[:y]
            while temp_pc != :empty
              # establishes that the pc in the temporary container is NOT the empty slot
              # where the dyadmino might go
              case dir
              when :se_to_nw; temp_y = (temp_y + vector) % @board_size
              when :eastwest; temp_x = (temp_x + vector) % @board_size
              when :sw_to_ne; temp_x, temp_y = (temp_x + vector) % @board_size, (temp_y - vector) % @board_size
              end
              if temp_x == lower_x && temp_y == lower_y
                temp_pc = lower_pc
              elsif temp_x == higher_x && temp_y == higher_y
                temp_pc = higher_pc
              else
                temp_pc = @filled_board_spaces[temp_y][temp_x]
              end
              if temp_sonority.count > max_card
                return :illegal_maxed_out_row
              elsif temp_pc != :empty && temp_sonority.include?(temp_pc)
                print temp_pc
                return :illegal_repeated_pcs
              elsif @rule < 3 # ensures there are no semitones when playing by folk and rock rules
                [-1, 1].each do |j|
                  if temp_pc != :empty && temp_sonority.include?(((temp_pc.to_i(12) + j) % 12).to_s(12))
                    return :illegal_semitones
                  end
                end
              end
              if temp_pc != :empty
                vector == -1 ? temp_sonority.unshift(temp_pc) : temp_sonority.push(temp_pc)
              end
            end
          end
        end
        array_of_sonorities << temp_sonority.sort!.join if temp_sonority.count > 1
      end
    end
    return array_of_sonorities
  end



@rule = 1
@board_size = 5
@filled_board_slots =  [%w(. . b . .),
                         %w(. a 3 7 1),
                          %w(. 0 . 2 .),
                           %w(. . . . .),
                            %w(. . . . .)]

print "The method returns #{scanSurroundingSlots("3", 1, 3, "5", 2, 2)}\n."

# don't forget to re replace :empty with :empty um, the opposite of that
