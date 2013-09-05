
@board_size = 300

def initi
  @filled_board_spaces = Array.new
  @board_size.times do # creates array of arrays of :empty symbol
    temp_array = Array.new
    @board_size.times { temp_array << :empty }
    @filled_board_spaces << temp_array
  end
  5.times do
    x = rand(@board_size)
    y = rand(@board_size)
    # print "non-empty space: #{x}, #{y}\n"
      @filled_board_spaces[y][x] = :bloop
  end
      # print "#{@filled_board_spaces}\n"
end

  def randomEmptyNeighborSpace
    array_of_empty_neighbor_spaces = Array.new
    @filled_board_spaces.each_index do |y|
      @filled_board_spaces[y].each_index do |x|
        if @filled_board_spaces[y][x] != :empty # this is the filled space
          [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]].each do |coord|
            temp_x, temp_y = (x + coord[0]) % @board_size, (y + coord[1]) % @board_size
            if @filled_board_spaces[temp_y][temp_x] == :empty
              array_of_empty_neighbor_spaces << [temp_x, temp_y]
            end
          end
        end
      end
    end
    random_coord = array_of_empty_neighbor_spaces.uniq.sample
    return random_coord[0], random_coord[1]
  end

  def hasFilledNeighborSpace?(x, y)
    # determines that a given empty space is next to a filled one on the board
    # DEV: refactor? similar to code in randomEmptyNeighborSpace
    [[1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1], [0, 1]].each do |coord|
      temp_x, temp_y = (x + coord[0]) % @board_size, (y + coord[1]) % @board_size
      if @filled_board_spaces[temp_y][temp_x] != :empty
        return true
      else
      end
    end
    return false
  end

initi
x, y = randomEmptyNeighborSpace
print "#{x}, #{y}\n"
print "#{hasFilledNeighborSpace?(x, y)}\n"
