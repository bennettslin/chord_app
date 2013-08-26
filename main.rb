require "gosu"

module ZOrder
  Background, Text, Tiles, PCs, FocusTiles, FocusPCs = *0..5
end

require_relative "window"
# require_relative "input_handler"
require_relative "player_options"
require_relative "tiles_state"
# require_relative "tile"

window = GameWindow.new
window.show
