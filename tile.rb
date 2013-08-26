class Tile
attr_reader :pcs, :x, :y

  def initialize(window, pcs, section, orient, x, y)
    @window = window
    @pcs = pcs
    @section = section
    @orient = orient
    @x = x
    @y = y
    @pcs_image = Array.new
    @pcs[0] = PCsImage.image(@pcs, @section)
    @dyadmino_image = DyadminoImage.image(@section, @orient)

  end

  def position(x, y)
    @x, @y = x, y
  end

  def turn_left
    @angle -=4.5
  end

  def turn_right
    @angle +=4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def reverse
    @vel_x -= Gosu::offset_x(@angle, 0.5)
    @vel_y -= Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= 640
    @y %= 480

    @vel_x *= 0.90
    @vel_y *= 0.90
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Player, @angle)
  end

  def score
    @score
  end
end



class DyadminoImage
  @dyadmino_rack = Gosu::Image.new(@window, "images/dyadmino_rack.png", true)
  @dyadmino_hor = Gosu::Image.new(@window, "images/dyadmino_board_hor.png", true)
  @dyadmino_ver = Gosu::Image.new(@window, "images/dyadmino_board_ver.png", true)
  # def image(section, orient)
  #   if section == "rack"
  #     @dyadmino_rack
  #   elsif section == "board" && orient == "hor"
  #     @dyadmino_hor
  #   else
  #     @dyadmino_ver
  #   end
  # end
end

class PCImage
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
  # def image(pcs, section)
  #   @pcs_rack[@rack[q][0].to_i(12)]
  # end
end

