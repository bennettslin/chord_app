def inPile # generate a pile of 66 dyadminos
	@pile = Array.new
	(0..11).each do |pc1| # first tile, pcs 0 to e
		(0..11).each do |pc2| # second tile, pcs 0 to e
			unless pc1 == pc2 # ensures no dyadmino has tiles of same pc
				thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join #converts to duodec. string
				@pile << thisDyad unless @pile.include?(thisDyad) #no duplicates
			end
		end
	end
end

def inRack # takes dyadminos from pile and puts in player's rack
  @rack = Array.new
  @pile.shuffle!
  8.times do |i| # number of dyadminos in player's rack, may change
    @rack << @pile[i]
    @pile.delete_at(i)
  end
  @rack.sort!
end

def onBoard
end

class Dyadmino
  attr_accessor :pcs, :x, :y, :orient, :size
end

def tileState # takes in array of dyadmino pc strings
  @rack_container = Array.new
  @rack.count.times do |i|
    @rack_slot = { pcs: @rack[i], :orient = 0, :x = (22 + 76 * i), :y = 816 }
    @rack_slot[:pcs] = @rack[i]
    @rack_slot[:orient] = 0
    @rackSlot
        x = 22 + (76 * q)
        y = 816

  @board_container

  end
  Dyadmino.new

end

def replaceRack(replaceDyads) # takes in array of dyadmino id numbers from player's rack and replaces only those
  rep_num = replaceDyads.count
  held_in_hand = Array.new # so that player doesn't get back any of the same dyadminos
  @pile.shuffle!
  rep_num.times do |i| # puts dyadminos back in pile
    held_in_hand << @rack[replaceDyads[(rep_num - 1) - i]]
    @rack.delete_at(replaceDyads[(rep_num - 1) - i]) # deletes in reverse to preserve order
  end
  rep_num.times do |i| # just like makeRack method, so maybe refactor later
    @rack << @pile[i]
    @pile.delete_at(i)
  end
  rep_num.times do |i| # now puts those dyadminos in the pile
    @pile << held_in_hand[(rep_num - 1) -i]
    held_in_hand.delete_at((rep_num - 1) -i)
  end
  @rack.sort!
end

# sandbox
# to code: make it so that player can't replace more than number of dyadminos left in pile (has to happens in player's replace input)

inPile
inRack

print "#{@pile.sort} \n"
print "#{@rack} \n"

replaceRack([0, 1, 2, 3])

print "#{@pile.sort} \n"
print "#{@rack} \n"
