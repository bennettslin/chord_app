class TilesState

  def initialize(rule)
    @legal_chords, @legal_incompletes = Array.new(2) { [] }
    @rule = rule
    case @rule # number of dyadminos in rack will vary by rules
      when 0; @rack_num = 6 # folk
      when 1, 2; @rack_num = 8 # rock, rock with classical
      when 3, 4; @rack_num = 10 # jazz, jazz with classical
      when 5; @rack_num = 5 # octatonic
      when 6; @rack_num = 6 # hexatonic and whole-tone
    else
    end
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    # board is hexagonal with x and y axes; the z axis is the (x = -y) diagonal line
    @board_size = 8 # mod number, kept small for dev purposes; for production,
    # board size should be large enough that players won't notice when edges wrap back around
    @board_spaces = Array.new # assigns board dyadminoes to board spaces for game logic
    @rack_slots = Array.new # assigns rack dyadminoes to rack slots
    @filled_board_spaces = Array.new # keeps track of which board slots are filled
    # y-axis value is the first argument, x-axis value is the second
    @board_size.times do # creates array of arrays of :empty symbol
      temp_array = Array.new
      @board_size.times { temp_array << :empty }
      @filled_board_spaces << temp_array
    end
    createLegalChords
    createPile
    initialRack
    initialBoard
    showPile
    showBoard
    showRack
  end

  def createLegalChords
    if @rule < 5 # only the tonal rules have ic prime forms and incomplete sevenths
      superset_chords = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
      superset_incompletes = [264, 237, 336, 273, 246, 174, 138, 147, 183]
      case @rule
        when 0; @legal_chords = superset_chords[0, 5]
        when 1, 2; @legal_chords = superset_chords[0, 8]
        when 3, 4; @legal_chords = superset_chords[0, 11]
      else
      end
      [11, 12].each { |i| @legal_chords.push(superset_chords[i]) } if [2, 4].include?(@rule)
      # These are the two augmented sixths legal under classical rules
      if @rule < 3
        @legal_incompletes = superset_incompletes[0, 5]
        # only the first five incompletes are legal under folk and rock rules;
        # the rest contain semitones
      else
        @legal_incompletes = superset_incompletes
      end
    # for DEV: change octatonic and hexatonic rules, these should be PC SETS
    elsif @rule == 5 # octatonic membership
      @legal_chords = [129, 138, 156, 237, 246, 336, 345, 1218, 1236, 1245, 1326, 1335, 1515,
        1272, 1263, 2334, 2424, 1353, 2343, 3333]
    elsif @rule == 6 # hexatonic and whole-tone
      @legal_chords = [138, 147, 228, 246, 345, 444, 1317, 1344, 1434, 2226, 2244, 2424, 1353]
    end
  end

# Pile state changes

  def createPile # generate a pile of 66 dyadminos
    (0..11).each do |pc1| # first tile, pcs 0 to e
      (0..11).each do |pc2| # second tile, pcs 0 to e
        temp_ic = [(pc1 - pc2).abs, (pc2 - pc1).abs].min
        unless pc1 == pc2 || @rule == 0 && [1, 2, 6].include?(temp_ic) ||
          [1, 2].include?(@rule) && [1, 2].include?(temp_ic)
          # no semitones, whole-tones, or tritones under folk rules
          # no semitones or whole-tones under rock rules
          thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join.to_sym
          @pile << thisDyad unless @pile.include?(thisDyad)
        end
      end
    end
    print "Pile count is #{@pile.count}.\n"
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
      # randomize whether lower-value pc is at top or bottom of rack
      # for dev in console, left pc is the top one, right pc is the bottom one
    else
      @rack_slots.delete_at(slot_num) # automatically reordered
    end
  end

# Rack state changes

  def flipDyadmino(slot_num)
    @rack_slots[slot_num][:orient] += 1 # value toggles between 0 and 1
    @rack_slots[slot_num][:orient] %= 2
    showRack
  end

  def swapDyadminos(slot_1, slot_2)
    @rack_slots[slot_1], @rack_slots[slot_2] =
      @rack_slots[slot_2], @rack_slots[slot_1]
    showRack
  end

# Board state changes

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    rack_orient = rand(2) # as if it had come from the rack
    board_orient = rand(6) # random orientation
    top_x = rand(@board_size) # random x, y coordinates
    top_y = rand(@board_size)
    # in each dyadmino, one pc always has a lower value than the other
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(top_x, top_y, rack_orient, board_orient)
    ontoBoard(fromPile, lower_x, lower_y, higher_x, higher_y)
  end

  def ontoBoard(pcs, lower_x, lower_y, higher_x, higher_y)
    @filled_board_spaces[lower_y][lower_x] = pcs[0]
    @filled_board_spaces[higher_y][higher_x] = pcs[1]
    @board_spaces << { pcs: pcs, lower_x: lower_x, lower_y: lower_y,
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
    # checks if board spaces are free and all possible sonorities made are legal;
    # if so, places dyadmino on board and refills rack from pile if possible;
    # otherwise, prints error message to user
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(top_x, top_y, @rack_slots[slot_num][:orient], board_orient)
    unless boardSlotsEmpty?(lower_x, lower_y, higher_x, higher_y)
      printMessage(:illegal_occupied_space, nil)
      return false
    else
      this_sonority = Array.new
      lower_pc, higher_pc = @rack_slots[slot_num][:pcs][0], @rack_slots[slot_num][:pcs][1]
      this_sonority =
        scanSurroundingSlots(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
      if this_sonority.class == Symbol
        printMessage(this_sonority, nil)
        return false
      else
        this_sonority.each do |son|
          if son.length >= 3 && checkLegalChord(son)
            printMessage(:legal_chord, son)
          elsif son.length < 3
            # monad or dyad, no message is needed
          elsif son.length == 3 && checkLegalIncomplete(son)
            printMessage(:legal_incomplete, son)
          else
            printMessage(:illegal_sonority, son)
            return false
          end
        end
      end
      ontoBoard(@rack_slots[slot_num][:pcs], lower_x, lower_y, higher_x, higher_y)
      showBoard
      intoRack(slot_num)
    end
    showRack
  end

# Helper methods

  def orientToBoard(top_x, top_y, rack_orient, board_orient) # changes rack orient to board coord
    bottom_x, bottom_y = top_x, top_y # temporarily makes bottom pc coords same as top
    x_deviate = y_deviate = 0 # how bottom coordinates deviate from top
    case board_orient # coords for two pcs will be off by one in one axis
      when 0; x_deviate = 1
      when 1; x_deviate, y_deviate = 1, -1
      when 2; y_deviate = - 1
      when 3; x_deviate = -1
      when 4; x_deviate, y_deviate = -1, 1
      when 5; y_deviate = 1
    end
    bottom_x = (top_x + x_deviate) % @board_size
    bottom_y = (top_y + y_deviate) % @board_size
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
    @filled_board_spaces[lower_y][lower_x] == :empty && @filled_board_spaces[higher_y][higher_x] == :empty
  end

  def centerBoard # shows center of smallest rectangle that encloses all played dyadminos
    # only for view purposes, data is unaffected
    min_x = min_y = @board_size - 1
    max_x = max_y = 0
    @board_size.times do |j|
      @board_size.times do |i|
        if @filled_board_spaces[j][i] != :empty
          min_x, min_y, max_x, max_y = [min_x, i].min, [min_y, j].min, [max_x, i].max, [max_y, j].max
        end
      end
    end
    center_x, center_y = (max_x + min_x) / 2, (max_y + min_y) / 2
    print "center of board is at #{center_x}, #{center_y}\n"
  end

  def printMessage(message, extra_arg)
    case message
      when :illegal_occupied_space
        print "You can't put one dyadmino on top of another.\n"
      when :illegal_maxed_out_row
        print "You can't have more than the max number in a row.\n"
      when :illegal_semitones
        print "You can't have semitones under folk or rock rules.\n"
      when :illegal_repeated_pcs
        print "You can't repeat the same pc in any given row.\n"
      when :legal_chord
            print "[#{extra_arg}] is a legal chord.\n"
      when :legal_incomplete
            print "[#{extra_arg}] is a legal incomplete seventh.\n"
      when :illegal_sonority
            print "[#{extra_arg}] isn't a legal sonority.\n"
    else
    end
  end

  def scanSurroundingSlots(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
    # ONLY checks if move is illegal for easy to detect physical reasons:
    # repeated pcs, maxed out rows, or semitones under folk or rock rules
    case @rule
      when (0..4) ; max_card = 4
      when 5; max_card = 8
      when 6; max_card = 6
    end
    array_of_sonorities = Array.new
    # this should be refactored
    directions_to_check = [{ pc: lower_pc, x: lower_x, y: lower_y, dir: :eastwest },
                            { pc: lower_pc, x: lower_x, y: lower_y, dir: :se_to_nw },
                            { pc: lower_pc, x: lower_x, y: lower_y, dir: :sw_to_ne },
                            { pc: higher_pc, x: higher_x, y: higher_y, dir: :eastwest },
                            { pc: higher_pc, x: higher_x, y: higher_y, dir: :se_to_nw },
                            { pc: higher_pc, x: higher_x, y: higher_y, dir: :sw_to_ne }]
    if lower_x == higher_x # so that same direction of dyadmino orientation isn't checked twice
      directions_to_check.delete_at(5)
    elsif lower_y == higher_y
      directions_to_check.delete_at(3)
    else
      directions_to_check.delete_at(4)
    end
    directions_to_check.each do |origin|
      temp_sonority = [origin[:pc]]
      [-1, 1].each do |vector| # checks in both directions
        temp_pc, temp_x, temp_y = String.new, origin[:x], origin[:y]
        while temp_pc != :empty
          # establishes that the pc in the temporary container is NOT the empty slot
          # where the dyadmino might go
          if origin[:dir] == :sw_to_ne
            temp_y = (temp_y + vector) % @board_size
          elsif origin[:dir] == :eastwest
            temp_x = (temp_x + vector) % @board_size
          elsif origin[:dir] == :se_to_nw
            temp_x, temp_y = (temp_x + vector) % @board_size, (temp_y - vector) % @board_size
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
            return :illegal_repeated_pcs
          elsif @rule < 3 # ensures there are no semitones when playing by folk and rock rules
            [-1, 1].each do |j|
              if temp_pc != :empty && temp_sonority.include?(((temp_pc.to_i(12) + j) % 12).to_s(12))
                return :illegal_semitones
              end
            end
          end
          if temp_pc != :empty
            vector == -1 ? temp_sonority.unshift(temp_pc) :
            temp_sonority.push(temp_pc)
          end
        end
      end
      array_of_sonorities << temp_sonority.sort!.join
    end
    return array_of_sonorities
  end

  def checkLegalIncomplete(sonority)
    icp_form, fake_root = getICPrimeForm(sonority)
    whether_legal_incomplete = isThisSonorityLegal?(icp_form, @legal_incompletes)
    return whether_legal_incomplete
  end

  def checkLegalChord(sonority)
    icp_form, fake_root = getICPrimeForm(sonority)
    whether_legal_chord = isThisSonorityLegal?(icp_form, @legal_chords)
    if whether_legal_chord
      # print "This is #{whether_legal_chord ? "legal" : "illegal"} under rule #{@rule}.\n"
      real_root, chord_type = getRootAndType(icp_form, fake_root)
      print "This is a #{real_root} #{chord_type}.\n"
    end
    return whether_legal_chord
  end

  def isThisSonorityLegal?(icp_form, array_of_sonorities)
    array_of_sonorities.include?(icp_form.to_i)
  end

# game logic

  def getICPrimeForm(sonority) # puts sonority in ic prime form (not pc prime form!)
    # this method won't necessarily work for sonorities of more than four pcs,
    # but for our purposes it's fine since four pcs is the maximum for this game.
    icp_form = String.new
    fake_root = 0 # not always the musical root, just used to id unique chord
    card = sonority.length
    pcn_form, icn_form, icn_sonorities, icp_sonorities = Array.new(4) { [] }

    sonority.split("").each do |i| # puts in pc normal form
      pcn_form << i.to_i(12) # converts from duodecimal string
    end
    pcn_form.sort! # puts pcs in arbitrary sequential order

    # converts pc normal form to ic normal form
    card.times do |i| # puts in ic normal form
      icn_form[i] = (pcn_form[(i + 1) % card] - pcn_form[i]) % 12
    end

    # converts ic normal form to ic prime form, and gives the more compact
    # ic prime form if there are post-tonal
    icn_sonorities[0] = icn_form
    icn_sonorities[1] = icn_form.reverse if @rule.between?(5, 6)
    icn_sonorities.count.times do |i|
      this_sonority = icn_sonorities[i]
      smallest_ics_index =
        this_sonority.each_index.select{ |j| this_sonority[j] == this_sonority.min }
        # selects however many index values there are of the smallest ic
      temp_max = first_ic_index = 0 # just declaring variables
      smallest_ics_index.each do |ic|
        temp_gap = this_sonority[(ic - 1) % card]
        if temp_gap > temp_max
          temp_max = temp_gap
          first_ic_index = ic
        end
      end

      fake_root = pcn_form[first_ic_index] unless @rule.between?(5, 6)
      temp_icp_form = ""
      card.times do |k| # puts in ic prime form
        temp_icp_form << this_sonority[(first_ic_index + k) % card].to_s(12) # rotates lineup
      end
      icp_sonorities[i] = temp_icp_form
    end

    @rule.between?(5, 6) ? icp_form =
      [icp_sonorities[0], icp_sonorities[1]].min : icp_form = icp_sonorities[0]
    print "The interval-class prime form of [#{sonority}] is (#{icp_form}).\n"
    return icp_form, fake_root
  end

  def getRootAndType(icp_form, fake_root) # returns string for real root
    real_root = String.new
    # refactor? same array as superset of tonal ics in method to create array of all legal chords
    tonal_ics = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
    t_names = ["minor triad", "major triad", "half-diminished seventh", "minor seventh",
              "dominant seventh", "diminished triad", "augmented triad", "fully diminished seventh",
              "minor-major seventh", "major seventh", "augmented major seventh",
              "Italian sixth", "French sixth"]
    t_adjust_root = [0, 8, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2] # adds to fake root to find correct root
    # for each symmetric chord, first value is ics, second value is mod number
    t_symmetric = [[444, 3333, 2424], [4, 3, 6]]
    t_index = tonal_ics.index(icp_form.to_i)
    sym_index = t_symmetric[0].index(tonal_ics[t_index])
    if sym_index != nil
      mod = t_symmetric[1][sym_index]
      (12 / mod).times do |i|
        real_root << (((fake_root + t_adjust_root[t_index])% mod) + (mod * i)).to_s(12)
      end
    else
      real_root = ((t_adjust_root[t_index] + fake_root) % 12).to_s(12)
    end
    return real_root, t_names[t_index]
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

  def showBoard # hexagonal board is really 2x2 board with extra diagonal
    # board size > 36 will create double-digit coordinates in console;
    # this is fine since this method is only for dev purposes
    centerBoard
    (@board_size - 1).step(0, -1) do |j|
      print "#{" " * j}#{j.to_s(36)}|"
      temp_array = @filled_board_spaces[j]
      @board_size.times do |i|
        print "#{temp_array[i] == :empty ? "." : temp_array[i]} "
      end
      case j
        when 2; print "  |  4 5  | how hexagonal orientation works:"
        when 1; print "   | 3 x 0 | top pc is located at x"
        when 0; print "    |  2 1  | bottom pc is located at number"
      end
      print "\n"
    end
    print " #{"-" * 2 * @board_size}\n"
    @board_size.times do |i|
      print "#{i.to_s(36)} "
    end
    print "\n"
  end

end
