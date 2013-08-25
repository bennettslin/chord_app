require 'gosu'

module ZOrder
  Background, Text, Tiles = *0..2
end

require_relative 'window'

window = GameWindow.new
window.show
