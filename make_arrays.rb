def makePile # generate a pile of 66 dyadminos
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

def makeRack # takes dyadminos from pile and puts in player's rack
  @rack = Array.new
  @pile.shuffle!
  8.times do |i| # number of dyadminos in player's rack, may change
    @rack << @pile[i]
    @pile.delete_at(i)
  end
