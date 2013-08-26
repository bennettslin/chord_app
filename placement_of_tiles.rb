require 'highline/import'

class Tiles

  def initialize
    @pile = Array.new # list of 66 dyadminoes by duodecimal notation
    @rack_num = 6 # will vary by level of difficulty
    @rack = Array.new # list of dyadminoes in rack by duodecimal notation
    @board_slots = Hash.new # assigns board dyadminoes to board slots
    @rack_slots = Hash.new # assigns rack dyadminoes to rack slots
  end

  def makePile # generate a pile of 66 dyadminos
  	(0..11).each do |pc1| # first tile, pcs 0 to e
  		(0..11).each do |pc2| # second tile, pcs 0 to e
  			unless pc1 == pc2 # ensures no dyadmino has tiles of same pc
  				thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join #converts to duodec. string
  				@pile << thisDyad unless @pile.include?(thisDyad) #no duplicates
  			end
  		end
  	end
  end

  def sortPile
    @pile.sort!
    half = (@pile.count / 2).round
    print "In pile:\n#{@pile[(0..(half - 1))].join(" ")}\n#{@pile[(half..-1)].join(" ")}\n"
  end

  def makeRack # takes dyadminos from pile and puts in player's rack
    @pile.shuffle!
    @rack_num.times do |i| # number of dyadminos in player's rack, may change
      @rack << @pile[i]
      @pile.delete_at(i)
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
    sortPile
    print "On your rack: #{temp_rack_slots.join(" ")} \n"
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

  def replaceDyadmino(slot_num) # swaps single dyadmino back into pile
    @pile.shuffle!
    temp_pc = @rack_slots[slot_num][:pcs]
    @rack_slots[slot_num][:pcs] = @pile.shift
    @pile << temp_pc
    onRackSlots
  end

  def swapDyadminos(slot_num, slot_swap)
    temp_pc = @rack_slots[slot_num][:pcs]
    temp_orient = @rack_slots[slot_num][:orient]
    @rack_slots[slot_num][:pcs] = @rack_slots[slot_swap][:pcs]
    @rack_slots[slot_num][:orient] = @rack_slots[slot_swap][:orient]
    @rack_slots[slot_swap][:pcs] = temp_pc
    @rack_slots[slot_swap][:orient] = temp_orient
    onRackSlots
  end
end

tiles = Tiles.new
tiles.makePile
tiles.makeRack

loop do
  askUser = ask("Enter slot number followed by 'f' to flip, 'r' to replace, or second slot number to swap\n(e.g., 2f, 4r, 13) or just 'q' to quit: ")
  slot_num = askUser[0].to_i(12)
  action = askUser[1]
  if askUser[0] == "q"
    break
  elsif action == "f"
    tiles.flipDyadmino(slot_num)
  elsif action == "r"
    tiles.replaceDyadmino(slot_num)
  else
    slot_swap = askUser[1].to_i(12)
    tiles.swapDyadminos(slot_num, slot_swap)
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
