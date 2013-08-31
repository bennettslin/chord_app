@pile = Array.new

  def createPile(rules) # generate a pile of 66 dyadminos
    @rules = rules
    (0..11).each do |pc1| # first tile, pcs 0 to e
      (0..11).each do |pc2| # second tile, pcs 0 to e
        unless pc1 == pc2 || @rules == 0 && [1, 2, 6].include?((pc1 - pc2).abs) ||
          [1, 2].include?(@rules) && (pc1 - pc2).abs == 1
          thisDyad = [pc1.to_s(12), pc2.to_s(12)].sort.join.to_sym
          @pile << thisDyad unless @pile.include?(thisDyad)
        end
      end
    end
    # for dev
    # 57.times do
    #   @pile.pop
    # end
  end

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

7.times do |rules|
  print "When the rules are #{rules}\n"
  createPile(rules)
  showPile
  print "There are #{@pile.count} dyadminos\n\n"
end
