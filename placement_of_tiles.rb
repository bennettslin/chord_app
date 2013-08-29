require 'highline/import'

class TilePlacement

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @board_size = 16 # will vary with experimentation (15 for now)
    @board_slots = Array.new # assigns board dyadminoes to board slots for game logic
    @rack_slots = Array.new # assigns rack dyadminoes to rack slots
    @filled_board_slots = Array.new # keeps track of which board slots are filled, dots are empty
    @board_size.times do |i|
      @filled_board_slots[i] = "." * @board_size
    end
  end

# Pile state changes

  def createPile # generate a pile of 66 dyadminos
    (0..11).each do |pc1| # first tile, pcs 0 to e
      (0..11).each do |pc2| # second tile, pcs 0 to e
        unless pc1 == pc2 # ensures no dyadmino has tiles of same pc
          thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join.to_sym #converts to duodec. string
          @pile << thisDyad unless @pile.include?(thisDyad) #no duplicates
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
      when 0; bottom_y = (top_y + 1) % @board_size
      when 1; bottom_x = (top_x - 1) % @board_size
      when 2; bottom_y = (top_y - 1) % @board_size
      when 3; bottom_x = (top_x + 1) % @board_size
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
    print " "
    @board_size.times do |i|
      print "#{i.to_s(36)}"
    end
    print "\n"
    @board_size.times do |j|
      print "#{j.to_s(36)}#{@filled_board_slots[j]}\n"
    end
  end

end

# Game start

tiles = TilePlacement.new
tiles.createPile
tiles.initialRack
tiles.initialBoard
tiles.showPile
tiles.showBoard
tiles.showRack

# Player input

loop do
  puts "*" * 72
  ask_slot = ask("Enter slot number (0 through 5) to perform action:\n(or 'b' for board, 'r' for rack, 'p' for pile, or 'q' to quit)")
  if ask_slot[0].downcase == "q"
    break
  elsif ask_slot[0].downcase == "b"
    tiles.showBoard
  elsif ask_slot[0].downcase == "p"
    tiles.showPile
  elsif ask_slot[0].downcase == "r"
    tiles.showRack
  elsif
    slot_num = ask_slot[0].to_i
    if slot_num.between?(0, 5)
      ask_action = ask("Choose 'f' to flip, 'r' to replace, 'p' to play\nor second slot number to swap:")
      if ask_action[0].downcase == "f"
        tiles.flipDyadmino(slot_num)
      elsif ask_action[0].downcase == "r"
        tiles.replaceDyadmino(slot_num)
      elsif ask_action[0].downcase == "p"
        ask_top_x = ask("x-coordinate of top pc:")
        ask_top_y = ask("y-coordinate of top pc:")
        ask_board_orient = ask("orientation (0 through 3):")
        tiles.playDyadmino(slot_num, ask_top_x.to_i(36), ask_top_y.to_i(36), ask_board_orient.to_i)
        # game program ALWAYS orients each dyadmino based on lower and higher pcs
        # however, player's understanding of orientation is based on top and bottom pcs
      else
        slot_swap = ask_action[0].to_i
        if slot_swap.to_i.between?(0, 5) && slot_swap != slot_num
          tiles.swapDyadminos(slot_num, slot_swap)
        end
      end
    end
  end
end
