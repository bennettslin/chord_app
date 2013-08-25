class GameWindow < Gosu::Window

  def initialize
    super 640, 960, false # size of iPhone
    self.caption = "Dyadminos! - A Musical Tile Game"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 28)
    @dev_font = Gosu::Font.new(self, Gosu::default_font_name, 18)
    # colors
    @dark_green = Gosu::Color.new(0xdd004000)
    @green = Gosu::Color.new(0xdd008000)
    @board_brown = Gosu::Color.new(0xff23231f)
    @dark_brown = Gosu::Color.new(0xdd606040)
    @black = Gosu::Color.new(0xff000000)
    @brown = Gosu::Color.new(0xdd909060)
    @bright_text = Gosu::Color.new(0xddffffdd)
    #images
    @empty_slot = Gosu::Image.new(self, "images/empty_slot.png", true)
    @dyadmino_rack = Gosu::Image.new(self, "images/dyadmino_rack.png", true)

  end

  def needs_cursor?
    true
  end

  def update
    # if button_down? Gosu::Ms
  end

  def draw
    draw_quad(0,40,@dark_green, 640,40,@dark_green, 640,100,@green, 0,100,@green, ZOrder::Background) # header, height 60
    draw_quad(0,100,@board_brown, 640,100,@board_brown, 640,800,@board_brown, 0,800,@board_brown, ZOrder::Background) # board
    draw_quad(0,800,@board_brown, 640,800,@board_brown, 640,960,@black, 0,960,@black, ZOrder::Background) # footer, height 160
    #header buttons
    @font.draw_rel("REPLACE", 20, 70, ZOrder::Text, 0, 0.5, 0.7, 1, @bright_text)
    @font.draw_rel("SUBMIT", 135, 70, ZOrder::Text, 0, 0.5, 0.7, 1, @bright_text)
    @font.draw_rel("Score: 00 - 00", 230, 70, ZOrder::Text, 0, 0.5, 0.7, 1, @bright_text)
    @font.draw_rel("SIZE", 370, 70, ZOrder::Text, 0, 0.5, 0.7, 1, @bright_text)
    @font.draw_rel("NOTATE", 437, 70, ZOrder::Text, 0, 0.5, 0.7, 1, @bright_text)
    @font.draw_rel("GIVE UP", 620, 70, ZOrder::Text, 1, 0.5, 0.7, 1, @bright_text)


    # dev text
    if button_down? Gosu::KbEscape
      close
    end
    if button_down? Gosu::MsLeft
      mouse_click = "Click!"
    else
      mouse_click = ""
    end
    @dev_font.draw_rel("#{Time.now}", 320, 20, ZOrder::Text, 0.5, 0.5, 1, 1, @bright_text)
    @dev_font.draw("Mouse x, y: #{mouse_x.to_i}, #{mouse_y.to_i}", 10, 748, ZOrder::Text, 1, 1, @bright_text)
    @dev_font.draw("#{mouse_click}", 200, 748, ZOrder::Text, 1, 1, @bright_text)

    #initial board
    15.times do |q| # draws 15 x 15 board of 42 x 42px monotiles, board padding of 5, 35
      x = 5 + (42 * q)
      15.times do |r|
        y = 110 + (42 * r) # make 136 after dev
        @empty_slot.draw(x, y, ZOrder::Background)
      end
    end

    #initial rack
    8.times do |q| # draws rack of 64 x 128px dyadminos, footer padding of 16, 10, dyadmino margin of 6
      x = 22 + (76 * q)
      y = 816
      @dyadmino_rack.draw(x, y, ZOrder::Tiles)
    end


  end
end
