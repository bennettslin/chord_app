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
    sortPile
  end

  def sortPile
    @pile.sort!
    half = (@pile.count / 2).round
    print "In the pile:\n#{@pile[(0..(half - 1))].join(" ")}\n#{@pile[(half..-1)].join(" ")}\n"
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
    onRackSlots
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

  def initialBoard # places random dyadmino from pile randomly onto board to start game
    @pile.shuffle!
    @board << @pile.pop
    temp_orient = rand(4)
    temp_x = 0
    temp_y = 0
    origin_x = rand(15)
    origin_y = rand(15)
    @board_slots[0] = { pcs: @board[0], x: temp_x, y: temp_y, orient: temp_orient} # coordinates of lower pc
    @filled_board_slots[origin_y][origin_x] = @board_slots[0][:pcs][0] # first pc
    case temp_orient
    when 0; temp_x = 1
    when 1; temp_y = 1
    when 2; temp_x = -1
    when 3; temp_y = -1
    end
    @filled_board_slots[(origin_y + temp_y) % 15][(origin_x + temp_x) % 15] = @board_slots[0][:pcs][1] # first pc
    onBoard
  end

  def onBoard
    print "On the board:\n"
    15.times do |i|
      print "#{@filled_board_slots[i]}\n"
    end
  end

  def flipDyadmino(pc)
    orientation = @rack_slots[pc][:orient]
    if orientation == 0
      @rack_slots[pc][:orient] = 180
    else
      @rack_slots[pc][:orient] = 0
    end
    onRackSlots
  end

  def swapDyadminos(pc1, pc2)
    temp_pc = @rack_slots[pc1][:pcs]
    temp_orient = @rack_slots[pc1][:orient]
    @rack_slots[pc1][:pcs] = @rack_slots[pc2][:pcs]
    @rack_slots[pc1][:orient] = @rack_slots[pc2][:orient]
    @rack_slots[pc2][:pcs] = temp_pc
    @rack_slots[pc2][:orient] = temp_orient
    onRackSlots
  end

  def replaceDyadmino(pc) # swaps single dyadmino back into pile
    @pile.shuffle!
    temp_pc = @rack_slots[pc][:pcs]
    @rack_slots[pc][:pcs] = @pile.shift
    @pile << temp_pc
    sortPile
    onRackSlots
  end

  # def playDyadmino(pc)

end

tiles = TilePlacement.new
tiles.createPile
tiles.onBoard
tiles.initialRack

loop do
  askSlot = ask("Enter slot number (0 through 5) or 'q' to quit:")
  if askSlot[0].downcase == "q"
    break
  elsif
    slot_num = askSlot[0].to_i
    if slot_num.between?(0, 5)
      askAction = ask("Choose 'f' to flip, 'r' to replace, 'p' to play\nor second slot number to swap.")
      if askAction[0] == "f"
        tiles.flipDyadmino(slot_num)
      elsif askAction[0] == "r"
        tiles.replaceDyadmino(slot_num)
      elsif askAction[0] == "p"
        tiles.playDyadmino(slot_num)
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
