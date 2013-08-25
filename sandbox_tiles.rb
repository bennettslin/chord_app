# sandbox tiles
require 'gosu'

class GameWindow < Gosu::Window

def initialize
  super 400, 400, false
  self.caption = "Sandbox tiles"
  @pcs_array = Gosu::Image::load_tiles(self, "images/pcs_board.png", 42, 42, false)
end

def update

end

def draw
  @pcs.draw(10, 10, 10)
end

end

class PC

def initialize

end

window = GameWindow.new
window.show
