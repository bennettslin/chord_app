require 'highline/import'

class TilePlacement

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @board_slots = Array.new # assigns board dyadminoes to board slots
    @rack_slots = Array.new # assigns rack dyadminoes to rack slots
    @filled_board_slots = Array.new # keeps track of which board slots are filled, dots are empty
    15.times do |i|
      @filled_board_slots[i] = "." * 15
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
  end

  # Pile

  def fromPile # draws random dyadmino from pile
    @pile.shuffle!
    @pile.pop
  end

  def intoPile(pcs) # takes dyadmino back into pile
    @pile.push(pcs)
  end

  def showPile # shows sorted pile
    @pile.sort!
    half = (@pile.count / 2).round
    print "In the pile:\n#{@pile[(0..half)].join(" ")}\n#{@pile[((half + 1)..-1)].join(" ")}\n"
  end

  # Rack

  def initialRack # puts starting dyadminos in rack
    @rack_num.times do |slot_num| # number of dyadminos in player's rack, may change
      intoRack(fromPile, slot_num)
    end
    @rack_slots.sort_by! { |hash| hash[:pcs] }
  end

  def showRack # shows which rack pieces are in which rack slots, and how oriented
    print "On your rack:\n0  1  2  3  4  5\n"
    @rack_num.times do |i|
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
    @rack_slots[slot_num][:orient] += 2 # toggles between 0 and 2,
    @rack_slots[slot_num][:orient] %= 4 # will be 0 and 3 for hex tiles
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
    held_pc = @rack_slots[slot_num][:pcs] # ensures different dyadmino from pile
    @rack_slots[slot_num][:pcs] = fromPile
    intoPile(held_pc)
    showPile
    showRack
  end

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    rand_orient = rand(4) # random orientation
    rand_x = rand(15) # random x, y coordinates
    rand_y = rand(15)
    ontoBoard(fromPile, rand_x, rand_y, rand_orient )
  end

  def showBoard
    print "On the board:\n"
    15.times do |i|
      print "#{@filled_board_slots[i]}\n"
    end
  end

  def ontoBoard(pcs, x, y, orient) # places on board after ensuring slots are free
    second_x = x
    second_y = y
    case orient
      when 0; second_x = (x + 1) % 15
      when 1; second_y = (y + 1) % 15
      when 2; second_x = (x - 1) % 15
      when 3; second_y = (y - 1) % 15
    else
    end
    if @filled_board_slots[y][x] == "." && @filled_board_slots[second_y][second_x] == "."
      @board_slots << { pcs: pcs, x: x, y: y, orient: orient }
      @filled_board_slots[y][x] = pcs[0]
      @filled_board_slots[second_y][second_x] = pcs[1]
    else
      return 0 # This means at least one of the slots is occupied.
    end
  end

  def playDyadmino(slot_num, x, y, orient) # note that board orient is rack orient plus user input
    if ontoBoard(@rack_slots[slot_num][:pcs], x, y, (@rack_slots[slot_num][:orient] + orient) % 4) != 0
      @board_slots << { pcs: @rack_slots[slot_num][:pcs], x: x, y: y, orient: orient}
      @filled_board_slots[y][x] = @board_slots[-1][:pcs][0]
      @rack_slots[slot_num][:pcs] = fromPile
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

# def replaceRack(replaceDyads) # takes in array of dyadmino id numbers from player's rack and replaces only those
#   rep_num = replaceDyads.count
#   held_in_hand = Array.new # so that player doesn't get back any of the same dyadminos
#   @pile.shuffle!
#   rep_num.times do |i| # puts dyadminos back in pile
#     held_in_hand << @rack[replaceDyads[(rep_num - 1) - i]]
#     @rack.delete_at(replaceDyads[(rep_num - 1) - i]) # deletes in reverse to preserve order
#   end
#   rep_num.times do |i| # just like makeRack method, so maybe refactor later
#     @rack << @pile[i]
#     @pile.delete_at(i)
#   end
#   rep_num.times do |i| # now puts those dyadminos in the pile
#     @pile << held_in_hand[(rep_num - 1) -i]
#     held_in_hand.delete_at((rep_num - 1) -i)
#   end
#   @rack.sort!
# end

# tiles.replaceRack([0, 1, 2, 3])
