class TilesState

  def initialize(window)
    @window = window
    @rack_num = 8 # move this later
    @dyadmino_rack = Gosu::Image.new(@window, "images/dyadmino_rack.png", true)
    @dyadmino_hor = Gosu::Image.new(@window, "images/dyadmino_board_hor.png", true)
    @dyadmino_ver = Gosu::Image.new(@window, "images/dyadmino_board_ver.png", true)
    @pcs_board = Array.new
    @pcs_board[0] = Gosu::Image.new(@window, "images/pcs_board-01.png", true) # definitely refactor
    @pcs_board[1] = Gosu::Image.new(@window, "images/pcs_board-02.png", true)
    @pcs_board[2] = Gosu::Image.new(@window, "images/pcs_board-03.png", true)
    @pcs_board[3] = Gosu::Image.new(@window, "images/pcs_board-04.png", true)
    @pcs_board[4] = Gosu::Image.new(@window, "images/pcs_board-05.png", true)
    @pcs_board[5] = Gosu::Image.new(@window, "images/pcs_board-06.png", true)
    @pcs_board[6] = Gosu::Image.new(@window, "images/pcs_board-07.png", true)
    @pcs_board[7] = Gosu::Image.new(@window, "images/pcs_board-08.png", true)
    @pcs_board[8] = Gosu::Image.new(@window, "images/pcs_board-09.png", true)
    @pcs_board[9] = Gosu::Image.new(@window, "images/pcs_board-10.png", true)
    @pcs_board[10] = Gosu::Image.new(@window, "images/pcs_board-11.png", true)
    @pcs_board[11] = Gosu::Image.new(@window, "images/pcs_board-12.png", true)
    @pcs_rack = Array.new
    @pcs_rack[0] = Gosu::Image.new(@window, "images/pcs_rack-01.png", true)
    @pcs_rack[1] = Gosu::Image.new(@window, "images/pcs_rack-02.png", true)
    @pcs_rack[2] = Gosu::Image.new(@window, "images/pcs_rack-03.png", true)
    @pcs_rack[3] = Gosu::Image.new(@window, "images/pcs_rack-04.png", true)
    @pcs_rack[4] = Gosu::Image.new(@window, "images/pcs_rack-05.png", true)
    @pcs_rack[5] = Gosu::Image.new(@window, "images/pcs_rack-06.png", true)
    @pcs_rack[6] = Gosu::Image.new(@window, "images/pcs_rack-07.png", true)
    @pcs_rack[7] = Gosu::Image.new(@window, "images/pcs_rack-08.png", true)
    @pcs_rack[8] = Gosu::Image.new(@window, "images/pcs_rack-09.png", true)
    @pcs_rack[9] = Gosu::Image.new(@window, "images/pcs_rack-10.png", true)
    @pcs_rack[10] = Gosu::Image.new(@window, "images/pcs_rack-11.png", true)
    @pcs_rack[11] = Gosu::Image.new(@window, "images/pcs_rack-12.png", true)

    #initial pile of 66 dyadminos
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
    makePile

    #initial player rack
    def makePlayerRack # takes dyadminos from pile and puts in player's rack
      @rack = Array.new
      @pile.shuffle!
      @rack_num.times do |i| # number of dyadminos in player's rack, may change
        q_margin = (((600 / @rack_num) - 64) / 2)
        q = 20 + q_margin + ((64 + (2 * q_margin)) * i)
        r = 816
        @rack[i] = { pcs: @pile[i], section: :rack, orient: 0, x: q, y: r }
        # each dyadmino is a hash, orient is 0 for regular, 1 for upside down
        @pile.delete_at(i)
      end
    end
    makePlayerRack
  end

  def draw
    def drawRackDyadminos # draw blank dyadminos on initial rack
      @rack_num.times do |i| # draws rack of 64 x 128px dyadminos
        pc1 = @rack[i][:pcs][(@rack[i][:orient]) % 2].to_i(12)
        pc2 = @rack[i][:pcs][(@rack[i][:orient] + 1) % 2].to_i(12)
        @dyadmino_rack.draw(@rack[i][:x], @rack[i][:y], ZOrder::Tiles)
        @pcs_rack[pc1].draw(@rack[i][:x], @rack[i][:y], ZOrder::PCs) # top pc
        @pcs_rack[pc2].draw(@rack[i][:x], (@rack[i][:y] + 64), ZOrder::PCs) # bottom pc
      end
    end
    drawRackDyadminos
  end

end
