# make dyadminos into rack random order and orientation?

require 'highline/import'

class TilePlacement

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @board_size = 15 # will vary with experimentation
    @board_slots = Array.new # assigns board dyadminoes to board slots
    @rack_slots = Array.new # assigns rack dyadminoes to rack slots
    @filled_board_slots = Array.new # keeps track of which board slots are filled, dots are empty
    @board_size.times do |i|
      @filled_board_slots[i] = "." * @board_size
    end
  end

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

  def showPile # shows sorted pile
    if @pile.count >= 1
      @pile.sort!
      if @pile.count >= 20
        half = (@pile.count / 2).round
        print "In the pile:\n#{@pile[(0..half)].join(" ")}\n#{@pile[((half + 1)..-1)].join(" ")}\n"
      else
        print "In the pile:\n#{@pile.join(" ")}\n"
      end
    end
  end

  def initialRack # puts starting dyadminos in rack
    @rack_num.times do |slot_num| # number of dyadminos in player's rack, may change
      intoRack(fromPile, slot_num)
    end
    @rack_slots.sort_by! { |hash| hash[:pcs] }
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

  def intoRack(pcs, slot_num)
    @rack_slots[slot_num] = { pcs: pcs, orient: 0 }
  end

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

  def replaceDyadmino(slot_num) # swaps single dyadmino back into pile
    if @pile.count >= 1 # does nothing if pile is empty
      held_pc = @rack_slots[slot_num][:pcs] # ensures different dyadmino from pile
      @rack_slots[slot_num][:pcs] = fromPile
      intoPile(held_pc)
    end
    showPile
    showRack
  end

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    rand_orient = rand(4) # random orientation
    rand_x = rand(@board_size) # random x, y coordinates
    rand_y = rand(@board_size)
    ontoBoard(fromPile, rand_x, rand_y, 0, rand_orient )
  end

  def showBoard
    print "On the board:\n"
    @board_size.times do |i|
      print "#{@filled_board_slots[i]}\n"
    end
  end

  def ontoBoard(pcs, x, y, rack_orient, orient) # places on board after ensuring slots are free
    other_x = x
    other_y = y
    case orient # for hex board, there will be six orientations
      when 0; other_x = (x + 1) % @board_size
      when 1; other_y = (y + 1) % @board_size
      when 2; other_x = (x - 1) % @board_size
      when 3; other_y = (y - 1) % @board_size
    else
    end
    if @filled_board_slots[y][x] == "." && @filled_board_slots[other_y][other_x] == "."
      @board_slots << { pcs: pcs, x: x, y: y, rack_orient: rack_orient, orient: orient }
      @filled_board_slots[y][x] = pcs[(rack_orient) % 2]
      @filled_board_slots[other_y][other_x] = pcs[(1 + rack_orient) % 2]
    else
      return 0 # This means at least one of the slots is occupied.
    end
  end

  def playDyadmino(slot_num, x, y, orient)
    # needs extra rack_orient parameter because player's understanding of orient is based on rack
    if ontoBoard(@rack_slots[slot_num][:pcs], x, y, @rack_slots[slot_num][:orient], orient) != 0
      if @pile.count >= 1
        @rack_slots[slot_num] = { pcs: fromPile, orient: 0 }
      else
        @rack_slots.delete_at(slot_num) # automatically reordered
      end
      showBoard
      showRack
    else
      print "Those slots are occupied.\n"
      showRack
    end
  end

end

tiles = TilePlacement.new
tiles.createPile
tiles.initialRack
tiles.initialBoard
tiles.showPile
tiles.showBoard
tiles.showRack

loop do
  puts "*" * 72
  askSlot = ask("Enter slot number (0 through 5) to perform action:\n(or 'b' for board, 'r' for rack, 'p' for pile, or 'q' to quit)")
  if askSlot[0].downcase == "q"
    break
  elsif askSlot[0].downcase == "b"
    tiles.showBoard
  elsif askSlot[0].downcase == "p"
    tiles.showPile
  elsif askSlot[0].downcase == "r"
    tiles.showRack
  elsif
    slot_num = askSlot[0].to_i
    if slot_num.between?(0, 5)
      askAction = ask("Choose 'f' to flip, 'r' to replace, 'p' to play\nor second slot number to swap:")
      if askAction[0].downcase == "f"
        tiles.flipDyadmino(slot_num)
      elsif askAction[0].downcase == "r"
        tiles.replaceDyadmino(slot_num)
      elsif askAction[0].downcase == "p"
        askX = ask("x coordinate:")
        askY = ask("y coordinate:")
        askOrient = ask("orientation (0 through 3):")
        tiles.playDyadmino(slot_num, askX.to_i, askY.to_i, askOrient.to_i)
      else
        slot_swap = askAction[0].to_i
        if slot_swap.to_i.between?(0, 5) && slot_swap != slot_num
          tiles.swapDyadminos(slot_num, slot_swap)
        end
      end
    end
  end
end
