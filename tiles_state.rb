class TilesState

  def initialize(rule)
    @testing == false # true represents a testing environment
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
    @board_size = 25 # mod number, kept small for dev purposes; for production,
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
      @tonal_chord_names = ["minor triad", "major triad", "half-diminished seventh", "minor seventh",
          "dominant seventh", "diminished triad", "augmented triad", "fully diminished seventh",
          "minor-major seventh", "major seventh", "augmented major seventh",
          "Italian sixth", "French sixth"]
      @superset_chords = [345, 354, 2334, 2343, 2433, 336, 444, 3333, 1344, 1434, 1443, 246, 2424]
      @superset_incompletes = [264, 237, 336, 273, 246, 174, 138, 147, 183]
      case @rule
        when 0; @legal_chords = @superset_chords[0, 5]
        when 1, 2; @legal_chords = @superset_chords[0, 8]
        when 3, 4; @legal_chords = @superset_chords[0, 11]
      else
      end
      [11, 12].each { |i| @legal_chords.push(@superset_chords[i]) } if [2, 4].include?(@rule)
      # These are the two augmented sixths legal under classical rules
      if @rule < 3
        @legal_incompletes = @superset_incompletes[0, 5]
        # only the first five incompletes are legal under folk and rock rules;
        # the rest contain semitones
      else
        @legal_incompletes = @superset_incompletes
      end
    # for DEV: change octatonic and hexatonic rules, these should be PC SETS
    elsif @rule == 5 # octatonic membership
      @legal_chords = [129, 138, 156, 237, 246, 336, 345, 1218, 1236, 1245, 1326, 1335, 1515,
        1272, 1263, 2334, 2424, 1353, 2343, 3333]
    elsif @rule == 6 # hexatonic and whole-tone
      @legal_chords = [138, 147, 228, 246, 345, 444, 1317, 1344, 1434, 2226, 2244, 2424, 1353]
    end
  end

# PILE STATE CHANGES

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

# PILE-RACK STATE CHANGES

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

  def replaceDyadmino(slot_num) # swaps single dyadmino back into pile
    if @pile.count >= 1 # does nothing if pile is empty
      held_pc = @rack_slots[slot_num][:pcs] # ensures different dyadmino from pile
      intoRack(slot_num)
      intoPile(held_pc)
    end
    showPile
    showRack
  end

# RACK STATE CHANGES

  def flipDyadmino(slot_num)
    @rack_slots[slot_num][:orient] += 1 # value toggles between 0 and 1
    @rack_slots[slot_num][:orient] %= 2
    showRack unless @testing
  end

  def swapDyadminos(slot_1, slot_2)
    @rack_slots[slot_1], @rack_slots[slot_2] =
      @rack_slots[slot_2], @rack_slots[slot_1]
    showRack
  end

# BOARD STATE CHANGES

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    rack_orient = rand(2) # as if it had come from the rack
    board_orient = rand(6) # random orientation
    @center_x = rand(@board_size) # random x, y coordinates
    @center_y = rand(@board_size) # originally just rand(@board_size)
    # in each dyadmino, one pc always has a lower value than the other
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(@center_x, @center_y, rack_orient, board_orient)
    ontoBoard(fromPile, lower_x, lower_y, higher_x, higher_y)
  end

  def ontoBoard(pcs, lower_x, lower_y, higher_x, higher_y)
    @filled_board_spaces[lower_y][lower_x] = pcs[0]
    @filled_board_spaces[higher_y][higher_x] = pcs[1]
    @board_spaces << { pcs: pcs, lower_x: lower_x, lower_y: lower_y,
      higher_x: higher_x, higher_y: higher_y }
  end

# CONTROLLERS

  def playDyadmino(slot_num, top_x, top_y, board_orient)
    # first checks if physical placement of dyadmino is legal;
    # then checks whether all possible sonorities made are legal;
    # if so, places dyadmino on board and refills rack from pile if possible;
    # otherwise, prints error message to user
    legal_move = false
    lower_x, lower_y, higher_x, higher_y =
      orientToBoard(top_x, top_y, @rack_slots[slot_num][:orient], board_orient)
    if isOccupiedSpace?(lower_x, lower_y) || isOccupiedSpace?(higher_x, higher_y)
      print printMessage(:illegal_occupied_space, nil)
      return false
    elsif isIslandSpace?(lower_x, lower_y) && isIslandSpace?(higher_x, higher_y)
      print printMessage(:illegal_island, nil)
      return false
    else
      this_sonority = Array.new
      lower_pc, higher_pc = @rack_slots[slot_num][:pcs][0], @rack_slots[slot_num][:pcs][1]
      this_sonority =
        scanNeighboringSpaces(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
      if this_sonority.class == Symbol
        print printMessage(this_sonority, nil)
        return false
      else
        array_of_user_messages = Array.new
        this_sonority.each do |son|
          whether_legal_chord, chord_root_and_type = checkLegalChord(son)
          if son.length >= 3 && whether_legal_chord
            legal_move = true
            array_of_user_messages << printMessage(:legal_chord, chord_root_and_type)
          elsif son.length == 3 && checkLegalIncomplete(son)
            legal_move = true
            array_of_user_messages << printMessage(:legal_incomplete, son)
          elsif son.length < 3 # monad or dyad, no action or message
          else
            print printMessage(:illegal_sonority, son)
            return false
          end
        end
        array_of_user_messages.each { |message| print message }
        # ensures no sonority in the array is illegal before printing legal messages
      end
      if legal_move
        ontoBoard(@rack_slots[slot_num][:pcs], lower_x, lower_y, higher_x, higher_y)
        intoRack(slot_num)
        showBoard
      else
        print printMessage(:no_legal_sonority, nil)
        return false
      end
    end
    showRack
    return true if @testing
  end

  # very brute force approach, can definitely be made much more efficient
  def playRandomLegalChord
    # for dev purposes, maybe can be used later for AI opponent
    shuffled_rack_slot_nums = [*0..(@rack_slots.count - 1)].shuffle
    shuffled_board_orients = [*0..5].shuffle
    shuffled_empty_neighbor_spaces = returnEmptyNeighborSpaces.shuffle
    shuffled_empty_neighbor_spaces.each do |coord|
      x, y = coord[0], coord[1]
      shuffled_board_orients.each do |orient| # determines which orientations are legal
        shuffled_rack_slot_nums.each do |slot_num|
          @rack_slots[slot_num][:orient] = rand(2)
          2.times do
            return true if playDyadmino(slot_num, x, y, orient)
            flipDyadmino(slot_num)
          end
        end
      end
    end
    return false
  end

  def testing # makes this instance a testing environment
    @testing = true
  end

# BOARD LOGIC

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

  def scanNeighboringSpaces(lower_pc, lower_x, lower_y, higher_pc, higher_x, higher_y)
    # only checks if dyadmino placement is illegal for physical reasons:
    # repeated pcs, more than the maximum allowed in a row, and semitones under folk or rock rules
    # if legal, returns all sonorities larger than monads
    case @rule
      when (0..4) ; max_card = 4
      when 5; max_card = 8
      when 6; max_card = 6
    end
    array_of_sonorities = Array.new
    pcs_to_check = [{ pc: lower_pc, x: lower_x, y: lower_y },
      { pc: higher_pc, x: higher_x, y: higher_y }]
    directions_to_check = [:eastwest, :se_to_nw, :sw_to_ne]
    if lower_y == higher_y # ensures that same direction of dyadmino orientation isn't checked twice
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
                when :sw_to_ne; temp_x, temp_y = (temp_x + vector) % @board_size,
                  (temp_y - vector) % @board_size
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

  def isOccupiedSpace?(x, y)
    @filled_board_spaces[y][x] != :empty
  end

  def isIslandSpace?(x, y)
    # determines that a given empty space is not next to a filled one on the board
    [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]].each do |coord|
      temp_x, temp_y = (x + coord[0]) % @board_size, (y + coord[1]) % @board_size
      if @filled_board_spaces[temp_y][temp_x] != :empty
        return false
      else
      end
    end
    return true
  end

  def returnEmptyNeighborSpaces
    # scans board and returns an array of every empty space that has a filled neighbor
    array_of_empty_neighbor_spaces = Array.new
    @filled_board_spaces.each_index do |y|
      @filled_board_spaces[y].each_index do |x|
        if @filled_board_spaces[y][x] != :empty # this is the filled space
          [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]].each do |coord|
            temp_x, temp_y = (x + coord[0]) % @board_size, (y + coord[1]) % @board_size
            if @filled_board_spaces[temp_y][temp_x] == :empty
              array_of_empty_neighbor_spaces << [temp_x, temp_y]
            end
          end
        end
      end
    end
    return array_of_empty_neighbor_spaces.uniq!
  end

# MUSICAL LOGIC

  def checkLegalIncomplete(sonority)
    icp_form, fake_root = getICPrimeForm(sonority)
    whether_legal_incomplete = isThisSonorityLegal?(icp_form, @legal_incompletes)
    return whether_legal_incomplete
  end

  def checkLegalChord(sonority)
    icp_form, fake_root = getICPrimeForm(sonority)
    whether_legal_chord = isThisSonorityLegal?(icp_form, @legal_chords)
    if whether_legal_chord
      real_root, chord_type = getRootAndType(icp_form, fake_root)
    end
    return whether_legal_chord, [real_root, chord_type].join("-")
  end

  def isThisSonorityLegal?(icp_form, array_of_sonorities)
    array_of_sonorities.include?(icp_form.to_i)
  end

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
    # print "The interval-class prime form of [#{sonority}] is (#{icp_form}).\n"
    return icp_form, fake_root
  end

  def getRootAndType(icp_form, fake_root) # returns string for real root
    real_root = String.new
    # refactor? same array as superset of tonal ics in method to create array of all legal chords
    t_adjust_root = [0, 8, 2, 2, 2, 0, 0, 0, 1, 1, 1, 2, 2] # adds to fake root to find correct root
    # for each symmetric chord, first value is ics, second value is mod number
    t_symmetric = [[444, 3333, 2424], [4, 3, 6]]
    t_index = @superset_chords.index(icp_form.to_i)
    sym_index = t_symmetric[0].index(@superset_chords[t_index])
    if sym_index != nil
      mod = t_symmetric[1][sym_index]
      (12 / mod).times do |i|
        real_root << (((fake_root + t_adjust_root[t_index])% mod) + (mod * i)).to_s(12)
      end
    else
      real_root = ((t_adjust_root[t_index] + fake_root) % 12).to_s(12)
    end
    return convertPCIntegersToLetters(real_root), @tonal_chord_names[t_index]
  end

  def returnRandomSonority(card) # accepts a cardinal value
    sonority = Array.new
    until sonority.count == card
      temp_pc = rand(12).to_s(12)
      sonority << temp_pc unless sonority.include?(temp_pc)
    end
    return sonority.join("")
  end

  def testSonorityProbability(sample_size) # for dev purposes
    # returns probability that any given sonority is a legal chord or incomplete
    tally_of_legal_chords = Array.new(@legal_chords.count){ 0.0 }
    tally_of_legal_incompletes = Array.new(@legal_incompletes.count){ 0.0 }
    illegal_sonorities = 0.0
    sample_size.times do
      icp_form, fake_root = getICPrimeForm(returnRandomSonority(rand(2) + 3))
      if isThisSonorityLegal?(icp_form, @legal_chords)
        tally_of_legal_chords[@legal_chords.index icp_form.to_i] += 1.0
      elsif isThisSonorityLegal?(icp_form, @legal_incompletes) && icp_form.length == 3
        tally_of_legal_incompletes[@legal_incompletes.index icp_form.to_i] += 1.0
      else
        illegal_sonorities += 1.0
      end
    end
    print "\nLegal chords:\n"
    tally_of_legal_chords.count.times do |i|
      print "#{((tally_of_legal_chords[i] / sample_size) * 100).round(1)}% #{@tonal_chord_names[i]}\n"
    end
    print "\nLegal incompletes:\n"
    tally_of_legal_incompletes.count.times do |i|
      print "#{((tally_of_legal_incompletes[i] / sample_size) * 100).round(1)}% [#{@legal_incompletes[i]}]\n"
    end
    print "\nIllegal sonorities:\n#{((illegal_sonorities / sample_size) * 100).round(1)}\n"
  end

# VIEWS (for console)

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
    center_x, center_y = centerBoard
    origin_x, origin_y =
      center_x - (@board_size / 2), center_y - (@board_size / 2)
    print "center of board is at #{center_x}, #{center_y}\n"
    (@board_size - 1).step(0, -1) do |j|
      print "#{" " * j}#{((j + origin_y) % @board_size).to_s(36)}|"
      temp_array = @filled_board_spaces[(j + origin_y) % @board_size]
      @board_size.times do |i|
        # temp_array[i] = "t" if temp_array[i] == "a" # real post-tonal notation
        # temp_array[i] = "e" if temp_array[i] == "b"
        print "#{temp_array[(i + origin_x) % @board_size] == :empty ?
          "." : temp_array[(i + origin_x) % @board_size]} "
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
      print "#{((i + origin_x) % @board_size).to_s(36)} "
    end
    print "\n"
  end

  def centerBoard # shows center of smallest rectangle that encloses all played dyadminos
    # only for view purposes, data is unaffected
    # for DEV: figure out a better algorithm eventually
    min_x = max_x = @center_x
    min_y = max_y = @center_y
    # refactor, obviously
    min_y += -1 until (@filled_board_spaces[min_y % @board_size] - [:empty]).empty? ||
      min_y % @board_size == @center_y + 1
    max_y += 1 until (@filled_board_spaces[max_y % @board_size] - [:empty]).empty? ||
      max_y % @board_size == @center_y - 1
    # for DEV: I didn't know a better way to iterate across arrays within arrays
    # as if x and y axes were switched, so this needs to be refactored
    begin
      temp_array = Array.new
      min_x += -1
      @board_size.times { |j| temp_array << @filled_board_spaces[j][min_x % @board_size] }
    end until (temp_array - [:empty]).empty? || min_x % @board_size == @center_x + 1
    begin
      temp_array = Array.new
      max_x += 1
      @board_size.times { |j| temp_array << @filled_board_spaces[j][max_x % @board_size] }
    end until (temp_array - [:empty]).empty? || max_x % @board_size == @center_x - 1
    @center_x, @center_y = (max_x + min_x) / 2, (max_y + min_y) / 2
    return @center_x, @center_y
  end


  def printMessage(message, sonority_string)
    unless @testing
      case message
        when :illegal_occupied_space
          "You can't put one dyadmino on top of another.\n"
        when :illegal_island
          "Please place the dyadmino next to another one.\n"
        when :illegal_maxed_out_row
          "You can't have more than the max number in a row.\n"
        when :illegal_repeated_pcs
          "You can't repeat the same pc in any given row.\n"
        when :illegal_semitones
          "You can't have semitones under folk or rock rules.\n"
        when :illegal_sonority
          "[#{sonority_string}] isn't a legal sonority.\n"
        when :no_legal_sonority
          "You need at least one legal sonority.\n"
      end
    end
    case message
      when :legal_chord
        "#{sonority_string} is a legal chord.\n"
      when :legal_incomplete
        "[#{sonority_string}] is a legal incomplete seventh.\n"
      else
    end
  end

  def convertPCIntegersToLetters(pc_integer)
    pc_letter = Array.new
    sharp = "\u266f" # Unicode symbols for sharp and flat signs
    flat = "\u266d" # Sublime Text 2 console doesn't recognize them
    scale = ["C", "D", "E", "F", "G", "A", "B"]
    pc_integer.each_char do |pc|
      case pc.to_i(12)
        when 0; temp_pc_letter = "C"
        when 1; temp_pc_letter = "C#{sharp} /D#{flat} "
        when 2; temp_pc_letter = "D"
        when 3; temp_pc_letter = "D#{sharp} /E#{flat} "
        when 4; temp_pc_letter = "E"
        when 5; temp_pc_letter = "F"
        when 6; temp_pc_letter = "F#{sharp} /G#{flat} "
        when 7; temp_pc_letter = "G"
        when 8; temp_pc_letter = "G#{sharp} /A#{flat} "
        when 9; temp_pc_letter = "A"
        when 10; temp_pc_letter = "A#{sharp} /B#{flat} "
        when 11; temp_pc_letter = "B"
      end
      pc_letter << temp_pc_letter
    end
    return pc_letter.join("-")
  end

end
