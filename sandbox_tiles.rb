# sandbox tiles
require 'gosu'

class GameWindow < Gosu::Window

  def initialize
    super 400, 400, false
    self.caption = "Sandbox tiles"
    @pcs_list = Gosu::Image::load_tiles(self, "images/pcs_board.png", 42, 42, true)
    @pcs_array = Array.new
  end

  def update
    12.times do
      @pcs_array.push(PitchClass.new(@pcs_list))
    end
  end

  def draw
    @pcs_array.each { |pc| pc.draw }
  end

end

class PitchClass
  def initialize(input)
    @input = input
  end

  def draw
    @input.draw(50, 50, 3)
  end

end

window = GameWindow.new
window.show


