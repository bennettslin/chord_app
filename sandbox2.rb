
      @rack = Array.new
      @pile = %w(5f, 3t, 2v, 8x, 1z, 8g, 3s, 9b, 0c)
      8.times do |i| # number of dyadminos in player's rack, may change
        @rack[i] = { pcs: @pile[i], slot: "rack", orient: "ver" }
      end
      @rack.sort_by! { |hash| hash[:pcs] }

      puts @rack
      puts @rack.last

      puts @rack[5][:pcs]

      @rack.each do |hash|
        puts hash[:pcs]
      end

  @tiles_state.mouseClick(mouse_x.to_i, mouse_y.to_i, @mouse_hold)

  def mouseClick(mouse_x, mouse_y, mouse_hold)
    @rack.each do |hash|
      @focus ||= 0 # ensures only one dyadmino gets moved
        if mouse_x > hash[:x] && mouse_x < hash[:x] + 64
          if mouse_y > hash[:y] && mouse_y < hash[:y] + 128
            unless @focus == 1
              origin_q = hash[:x]
              origin_r = hash[:y]
              origin_x = mouse_x
              origin_y = mouse_y
        if mouse_x > origin_q && mouse_x < origin_q + 64
          if mouse_y > origin_r && mouse_y < origin_r + 128


          end
        end
      end
    end
  end

        if mouse_x > origin_q && mouse_x < origin_q + 64
        if mouse_y > origin_r && mouse_y < origin_r + 128
          if mouse_hold > 1
            hash[:x] = origin_q + mouse_x - origin_x
            hash[:y] = origin_r + mouse_y - origin_y
          else
            hash[:x] = origin_q
            hash[:y] = origin_r
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
