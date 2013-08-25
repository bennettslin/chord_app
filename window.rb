class GameWindow < Gosu::Window

  def initialize
    super 640, 960, false # size of iPhone
    self.caption = "Dyadminos! - A Musical Tile Game"
    @font = Gosu::Font.new(self, Gosu::default_font_name, 32)
    @dev_font = Gosu::Font.new(self, Gosu::default_font_name, 18)
    # colors
    @dark_green = Gosu::Color.new(0xdd004000)
    @green = Gosu::Color.new(0xdd008000)
    @dark_brown = Gosu::Color.new(0xdd606040)
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
    draw_quad(0,800,@brown, 640,800,@brown, 640,960,@dark_brown, 0,960,@dark_brown, ZOrder::Background) # footer, height 160

    #header buttons
    @font.draw("REPLACE", 20, 54, ZOrder::Text, 1, 1, @bright_text)
    @font.draw("Score: #", 225, 54, ZOrder::Text, 1, 1, @bright_text)
    @font.draw_rel("EXIT", 620, 54, ZOrder::Text, 1, 0, 1, 1, @bright_text)

    # dev text
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
    8.times do |q| # draws rack of 63 x 126 dyadminos, footer padding of 16, 10
      x = 23 + (76 * q)
      y = 816
      @dyadmino_rack.draw(x, y, ZOrder::Tiles)
    end
  end
end
