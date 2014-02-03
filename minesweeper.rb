# Require other classes

class MineSweeper

  def initialize(player)
    @player = player
  end

  def initialize_game(size_x, size_y)
    @game_board = Board.new([size_x, size_y])
    @game_board.create_game
  end

  def play_game
    # Ask player what size they want.  #initialize_game(with_size)
    initialize_game(9, 9)
    until game_over?
      puts @game_board
      coords = get_coords_from_player
      action = get_action_from_player
      case action
      when "1"
        @game_board.do_action(action, coords)
      when "2"
        @game_board.do_action(action, coords)
      when "3"
      else
        puts "Invalid Input."
      end

    end
  end

  def game_over?

  end

  def get_action_from_player
    puts "What would you like to do to that tile?"
    puts "1 = Reveal Tile  | 2 = Toggle Bomb Flag | 3 = Re-enter tile coordinates"
    @player.get_action
  end

  def get_coords_from_player
    puts "Please enter the x,y coordinates separated by a space of the tile you want to change:"
    @player.get_coords
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
      end
    end
    @board = board
  end

  def do_action(action, coords)
    x, y = coords[0], coords[1]
    case action
    when "1"
      @board[y][x].reveal
    when "2"
      @board[y][x].toggle_bomb_flag
    end
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
    @revealed = false
  end

  def reveal
    if @revealed
      puts "Tile has already been revealed!"
    elsif @display_value == "B"
      puts "You must un-toggle the tile before it can be revealed."
    else
      @revealed = true
      @display_value = " "
    end
  end

  def toggle_bomb_flag
    if @display_value == "B"
      @display_value = "@"
    else
      @display_value = "B"
    end
  end
end


class Player

  def initialize(name)
    @name = name
  end


  def get_coords
    offset_coordinates = gets.chomp.split(" ").map {|value| Integer(value)}
    [offset_coordinates[0] - 1, offset_coordinates[1] - 1]
  end

  def get_action
    gets.chomp
  end
end

player = Player.new("Kevin")
game = MineSweeper.new(player)

game.play_game