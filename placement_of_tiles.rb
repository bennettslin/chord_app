require 'highline/import'

class TilePlacement

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @board = Array.new # list of dyadminoes on board
    # @board might not be necessary, since @board_slots and @rack_slots keep same info
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

  def intoRack(pcs, slot_num)
    @rack_slots[slot_num] = { pcs: pcs, orient: 0 }
  end

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

  def flipDyadmino(slot_num)
    @rack_slots[slot_num][:orient] += 1 # toggles between 0 and 1
    @rack_slots[slot_num][:orient] %= 2
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

  def ontoBoard(pcs, x, y, orient)
    @board_slots << { pcs: pcs, x: x, y: y, orient: orient }
    temp_x ||= 0
    temp_y ||= 0
    case orient
    when 0; temp_x = 1
    when 1; temp_y = 1
    when 2; temp_x = -1
    when 3; temp_y = -1
    else
    end
    @filled_board_slots[y][x] = @board_slots[-1][:pcs][0] # first pc
    @filled_board_slots[(y + temp_y) % 15][(x + temp_x) % 15] = @board_slots[-1][:pcs][1] # first pc
  end

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    @board << fromPile
    rand_orient = rand(4)
    rand_x = rand(15)
    rand_y = rand(15)
    ontoBoard(fromPile, rand_x, rand_y, rand_orient )
  end

  def showBoard
    print "On the board:\n"
    15.times do |i|
      print "#{@filled_board_slots[i]}\n"
    end
  end

  def playDyadmino(slot_num, x, y, orient)
    temp_x = 0
    temp_y = 0
    @board_slots << { pcs: @rack_slots[slot_num][:pcs], x: x, y: y, orient: orient}
    @filled_board_slots[y][x] = @board_slots[-1][:pcs][0]
    case orient
    when 0; temp_x = 1
    when 1; temp_y = 1
    when 2; temp_x = -1
    when 3; temp_y = -1
    else
    end
    @filled_board_slots[(y + temp_y) % 15][(x + temp_x) % 15] = @board_slots.last[:pcs][1] # first pc
    # new test to see space not already filled
    # do playDyadmino
    showBoard
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
      if askAction[0] == "f"
        tiles.flipDyadmino(slot_num)
      elsif askAction[0] == "r"
        tiles.replaceDyadmino(slot_num)
      elsif askAction[0] == "p"
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
