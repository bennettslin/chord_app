require 'highline/import'

class TilePlacement

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @rack = Array.new # list of dyadminoes in rack
    @board = Array.new # list of dyadminoes on board
    # @rack and @board might not be necessary, since @board_slots and @rack_slots keep same info
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
  				thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join #converts to duodec. string
  				@pile << thisDyad unless @pile.include?(thisDyad) #no duplicates
  			end
  		end
  	end
  end

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    @pile.shuffle!
    @board << @pile.pop
    rand_orient = rand(4)
    temp_x = 0
    temp_y = 0
    origin_x = rand(15)
    origin_y = rand(15)
    @board_slots[0] = { pcs: @board[0], x: origin_x, y: origin_y, orient: rand_orient } # coordinates of lower pc
    @filled_board_slots[origin_y][origin_x] = @board_slots[0][:pcs][0] # first pc
    case rand_orient
    when 0; temp_x = 1
    when 1; temp_y = 1
    when 2; temp_x = -1
    when 3; temp_y = -1
    else
    end
    @filled_board_slots[(origin_y + temp_y) % 15][(origin_x + temp_x) % 15] = @board_slots[0][:pcs][1] # first pc
  end

  def initialRack # takes dyadminos from pile and puts in player's rack
    @pile.shuffle!
    @rack_num.times do |i| # number of dyadminos in player's rack, may change
      @rack << @pile.pop
    end
    @rack.sort!
    @rack_num.times do |i| # sets up orientation
      @rack_slots[i] = { pcs: @rack[i], orient: 0 } # 0 for 0 degrees, 1 for 180 degrees
    end
  end

  def sortPile
    @pile.sort!
    half = (@pile.count / 2).round
    print "In the pile:\n#{@pile[(0..half)].join(" ")}\n#{@pile[((half + 1)..-1)].join(" ")}\n"
  end

  def onRackSlots # keeps track of which rack pieces are in which rack slots, and how oriented
    temp_rack_slots = Array.new
    @rack_num.times do |i|
      if @rack_slots[i][:orient] == 0
        temp_rack_slots[i] = @rack_slots[i][:pcs]
      else
        temp_rack_slots[i] = @rack_slots[i][:pcs].reverse
      end
    end
    print "On your rack:\n0  1  2  3  4  5\n#{temp_rack_slots.join(" ")} \n"
  end

  def onBoardSlots
    print "On the board:\n"
    15.times do |i|
      print "#{@filled_board_slots[i]}\n"
    end
  end

  def flipDyadmino(slot_num)
    orientation = @rack_slots[slot_num][:orient]
    if orientation == 0
      @rack_slots[slot_num][:orient] = 180
    else
      @rack_slots[slot_num][:orient] = 0
    end
    onRackSlots
  end

  def swapDyadminos(slot_1, slot_2)
    temp_pc = @rack_slots[slot_1][:pcs]
    temp_orient = @rack_slots[slot_1][:orient]
    @rack_slots[slot_1][:pcs] = @rack_slots[slot_2][:pcs]
    @rack_slots[slot_1][:orient] = @rack_slots[slot_2][:orient]
    @rack_slots[slot_2][:pcs] = temp_pc
    @rack_slots[slot_2][:orient] = temp_orient
    onRackSlots
  end

  def replaceDyadmino(slot_num) # swaps single dyadmino back into pile
    @pile.shuffle!
    temp_pc = @rack_slots[slot_num][:pcs]
    @rack_slots[slot_num][:pcs] = @pile.shift
    @pile << temp_pc
    sortPile
    onRackSlots
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
    # remove played dyadmino from rack
    # remove random dyadmino from pile
    # place random dyadmino in rack
    # consolidate basic actions
    onBoardSlots
  end

end

tiles = TilePlacement.new
tiles.createPile
tiles.initialRack
tiles.initialBoard
tiles.sortPile
tiles.onRackSlots
tiles.onBoardSlots

loop do
  askSlot = ask("Enter slot number (0 through 5) to perform action:\n(or 'b' for board, 'r' for rack, 'p' for pile, or 'q' to quit)")
  if askSlot[0].downcase == "q"
    break
  elsif askSlot[0].downcase == "b"
    tiles.onBoardSlots
  elsif askSlot[0].downcase == "p"
    tiles.sortPile
  elsif askSlot[0].downcase == "r"
    tiles.onRackSlots
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
