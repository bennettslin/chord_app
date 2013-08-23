class GameWindow < Gosu::Window
  def initialize
    super 640, 960, false # size of iPhone
    self.caption = "Dyadminos! - A Musical Tile Game"
  end

  def needs_cursor?
    true
  end

  def update

  end

  def draw

  end
end
