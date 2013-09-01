class TilesState

  def initialize(rule)
    @legal_chords = LegalChords.new(rule).createLegalChords
    @rule = rule
    case @rule # number of dyadminos in rack will vary by rules
      when 0; @rack_num = 6
      when 1, 2; @rack_num = 8
      when 3, 4; @rack_num = 10
      when 5; @rack_num = 5
      when 6; @rack_num = 6
    else
    end
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @board_size = 8 # will vary with experimentation (15 for now)
    @board_slots = Array.new # assigns board dyadminoes to board slots for game logic
    @rack_slots = Array.new # assigns rack dyadminoes to rack slots
    @filled_board_slots = Array.new # keeps track of which board slots are filled, dots are empty
    @board_size.times do |i|
      @filled_board_slots[i] = "." * @board_size
    end
    createPile
    initialRack
    initialBoard
    showPile
    showBoard
    showRack
  end

# Pile state changes

  def createPile # generate a pile of 66 dyadminos
    (0..11).each do |pc1| # first tile, pcs 0 to e
      (0..11).each do |pc2| # second tile, pcs 0 to e
        unless pc1 == pc2 || @rule == 0 && [1, 2, 6].include?((pc1 - pc2).abs) ||
          [1, 2].include?(@rule) && (pc1 - pc2).abs == 1
          thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join.to_sym
          @pile << thisDyad unless @pile.include?(thisDyad)
        end
      end
    end
    # for dev
    # 57.times do
    #   @pile.pop
    # end
  end

  def fromPile # draws random dyadmino from pile
    @pile.shuffle!
    @pile.pop
  end

  def intoPile(pcs) # takes dyadmino back into pile
    @pile.push(pcs)
  end

# Pile into rack state changes

  def initialRack # puts starting dyadminos in rack
    @rack_num.times do |slot_num| # number of dyadminos in player's rack, may change
      intoRack(slot_num)
    end
    # uncomment to start out rack with dyadminos sorted by top pc (I'm leaning towards not)
    # @rack_slots.sort_by! { |hash| hash[:pcs] }
  end

  def intoRack(slot_num) # adds random dyadmino from pile, if available
    # deletes original dyadmino in rack slot EITHER WAY
    if @pile.count >= 1
      @rack_slots[slot_num] = { pcs: fromPile, orient: rand(2) }
      # randomize whether lower pc is at top or bottom
    else
      @rack_slots.delete_at(slot_num) # automatically reordered
    end
  end

# Rack state changes

  def flipDyadmino(slot_num)
    @rack_slots[slot_num][:orient] += 1 # toggles between 0 and 2,
    @rack_slots[slot_num][:orient] %= 2 # will be 0 and 3 for hex tiles
    showRack
  end

  def swapDyadminos(slot_1, slot_2)
    @rack_slots[slot_1][:pcs], @rack_slots[slot_2][:pcs] =
      @rack_slots[slot_2][:pcs], @rack_slots[slot_1][:pcs]
    @rack_slots[slot_1][:orient], @rack_slots[slot_2][:orient] =
      @rack_slots[slot_2][:orient], @rack_slots[slot_1][:orient]
    showRack
  end

# Board state changes

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    rack_orient = rand(2)
    board_orient = rand(4) # random orientation
    top_x = rand(@board_size) # random x, y coordinates
    top_y = rand(@board_size)
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(top_x, top_y, rack_orient, board_orient)
    ontoBoard(fromPile, lower_x, lower_y, higher_x, higher_y)
  end

  def ontoBoard(pcs, lower_x, lower_y, higher_x, higher_y)
    @filled_board_slots[lower_y][lower_x] = pcs[0]
    @filled_board_slots[higher_y][higher_x] = pcs[1]
    @board_slots << { pcs: pcs, lower_x: lower_x, lower_y: lower_y,
      higher_x: higher_x, higher_y: higher_y }
  end

# Controller actions

  def replaceDyadmino(slot_num) # swaps single dyadmino back into pile
    if @pile.count >= 1 # does nothing if pile is empty
      held_pc = @rack_slots[slot_num][:pcs] # ensures different dyadmino from pile
      @rack_slots[slot_num][:pcs] = fromPile
      intoPile(held_pc)
    end
    showPile
    showRack
  end

  def playDyadmino(slot_num, top_x, top_y, board_orient)
    # converts rack orient to board coord, checks if board slots are free,
    # then refills rack if possible
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(top_x, top_y, @rack_slots[slot_num][:orient], board_orient)
    if boardSlotsEmpty?(lower_x, lower_y, higher_x, higher_y)
      ontoBoard(@rack_slots[slot_num][:pcs], lower_x, lower_y, higher_x, higher_y)
      showBoard
      intoRack(slot_num)
    else
      print "Occupied.\n"
    end
    showRack
  end

# Helper methods

  def orientToBoard(top_x, top_y, rack_orient, board_orient) # changes rack orient to board coord
    bottom_x, bottom_y = top_x, top_y # temporarily makes bottom pc coords same as top
    case board_orient # coords for two pcs will be off by one in one axis
    # (for hex board, there will be six orients)
      when 1; bottom_y = (top_y + 1) % @board_size
      when 2; bottom_x = (top_x - 1) % @board_size
      when 3; bottom_y = (top_y - 1) % @board_size
      when 0; bottom_x = (top_x + 1) % @board_size
    else
    end
    # player's understanding of dyadmino orient is based on placement on rack;
    # this assigns board coord based on lower and higher pcs instead
    if rack_orient == 0
      lower_x, lower_y, higher_x, higher_y = top_x, top_y, bottom_x, bottom_y
    else
      lower_x, lower_y, higher_x, higher_y = bottom_x, bottom_y, top_x, top_y
    end
    return lower_x, lower_y, higher_x, higher_y
  end

  def boardSlotsEmpty?(lower_x, lower_y, higher_x, higher_y)
    @filled_board_slots[lower_y][lower_x] == "." && @filled_board_slots[higher_y][higher_x] == "."
  end

  def centerBoard # shows center of smallest rectangle that encloses all played dyadminos
    # only for view purposes, data is unaffected
    min_x = min_y = @board_size - 1
    max_x = max_y = 0
    @board_size.times do |j|
      @board_size.times do |i|
        if @filled_board_slots[j][i] != "."
          min_x, min_y, max_x, max_y = [min_x, i].min, [min_y, j].min, [max_x, i].max, [max_y, j].max
        end
      end
    end
    center_x, center_y = (max_x + min_x) / 2, (max_y + min_y) / 2
    print "center of board is at #{center_x}, #{center_y}\n"
  end

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

# Views

  def showPile # shows sorted pile
    if @pile.count >= 1
      @pile.sort!
      if @pile.count >= 20
        half = (@pile.count / 2)
        print "In the pile:\n#{@pile[(0..half)].join(" ")}\n#{@pile[((half + 1)..-1)].join(" ")}\n"
      else
        print "In the pile:\n#{@pile.join(" ")}\n"
      end
    end
  end

  def showRack # shows which rack pieces are in which rack slots, and how oriented
    print "On your rack:\n"
    @rack_slots.count.times do |i|
      print "#{i}  "
    end
    print "\n"
    @rack_slots.count.times do |i|
      if @rack_slots[i][:orient] == 0
        print "#{@rack_slots[i][:pcs]} "
      else
        print "#{@rack_slots[i][:pcs].to_s.reverse} "
      end
    end
    print "\n"
  end

  def showBoard
    centerBoard
    (@board_size - 1).step(0, -1) do |j|
      print "#{j.to_s(36)}|#{@filled_board_slots[j]}\n"
    end
    print "  #{"-" * @board_size}\n  "
    @board_size.times do |i|
      print "#{i.to_s(36)}"
    end
    print "\n"
  end

end
