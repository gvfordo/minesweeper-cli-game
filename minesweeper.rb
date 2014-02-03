# Require other classes

class MineSweeper

  def initialize(player)
    @player = player
  end

  def start_game(size_x, size_y)
    board = Board.new([size_x, size_y])
    board.create_game
    puts board
  end

end

class Board

  def initialize(size)
    @size_x, @size_y = size[0], size[1]

  end

  def create_game
    board = Array.new(@size_y) {Array.new(@size_x)}
    board.each_index do |y|
      board[y].each_index do |x|
        board[y][x] = Tile.new([x, y], [@size_x, @size_y], "@" )
        #p board[y][x]
      end
    end
    @board = board
  end

  def to_s
    string = ""
    @board.each do |row|
      row.each do |col|
        string += "#{col.display_value} "
      end
      string += "\n"
    end
    string
  end
end


class Tile
  attr_reader :display_value

  def initialize(pos, grid, display_value)
    @pos = pos  #Array pair ?  [0, 0]
    @grid =  grid #  [9, 9]
    @display_value = display_value
  end
end


class Player

  def initialize(name)
    @name = name
  end


  def get_coordinates
    coords = gets.chomp
  end
end

player = Player.new("Kevin")
game = MineSweeper.new(player)

game.start_game(9,9)