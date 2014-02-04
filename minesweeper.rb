# Require other classes
require 'yaml'
require 'colorize'
class MineSweeper

  GAME_TEXT = {
    :action_question => "What would you like to do to that tile?",
    :coords_question => "Please enter the x,y coordinates separated by a space of the tile you want to change:",
    :invalid_input => "Invalid Input.",
    :action_options => "1 = Reveal Tile  | 2 = Toggle Bomb Flag | 3 = Re-enter tile coordinates | 4 = Save Game",
    :already_revealed => "This tile has already been revealed!",
    :end => "Game Over,  YOU LOOOOOOOOSE",
    :has_bomb_flag => "You must un-toggle the tile before it can be revealed",
    :won => "You've won the game!",
    :saved_game => "You saved the game!"
  }

  def initialize(player)
    @player = player
  end

  def initialize_game(size_x, size_y)
    @game_board = Board.new([size_x, size_y])
    @game_board.create_game
  end

  def play_game(saved = false)
    # Ask player what size they want.  #initialize_game(with_size)
    initialize_game(20, 20) unless saved
    until game_over?
      puts @game_board
      coords = get_coords_from_player
      action = get_action_from_player
      if action == :reveal
        result = @game_board.reveal(coords)
        if result == :already_revealed
          puts GAME_TEXT[:already_revealed]
        elsif result == :has_bomb_flag
          puts GAME_TEXT[:has_bomb_flag]
        end
      elsif action == :toggle_flag
        @game_board.toggle_bomb_flag(coords)
        system("clear")
      elsif action == :save_game
        save_game
        puts GAME_TEXT[:saved_game]
        break
      end
    end

    if @game_board.won?
      puts GAME_TEXT[:won]
    else
      puts GAME_TEXT[:end]
    end
  end

  def game_over?
    @game_board.won? || @game_board.lost?
  end


  def get_action_from_player
    puts GAME_TEXT[:action_question]
    puts GAME_TEXT[:action_options]
    @player.get_action
  end

  def get_coords_from_player
    puts GAME_TEXT[:coords_question]
    @player.get_coords
  end

  def save_game
    saved_game = self.to_yaml

    File.open('save1.yaml', 'w'){ |file| file.puts saved_game }

  end

  def load_game

  end
end

class Board
  attr_reader :board



  def initialize(size, number_of_bombs = 20)
    @size_x, @size_y = size
    @number_of_bombs = number_of_bombs
  end

  def won?
    tiles = []
    board.each do |rows|
      rows.each do |col|
        tiles << col
      end
    end
    tiles.all? do |tile|
      (tile.has_bomb? ^ tile.revealed)
    end
  end

  def lost?
    @board.each do |rows|
      rows.each do |col|
        if col.revealed && col.has_bomb?
          return true
        end
      end
    end
    false
  end

  def create_game
    @board = Array.new(@size_y) { |row| Array.new(@size_x) { |col| Tile.new([col, row], [@size_x, @size_y]) } }
    seed_bombs

    board.each_index do |y|
      board[y].each_index do |x|
        adjacents = get_adjacents([x, y])
        board[y][x].adjacent_bombs = number_of_adjacent_bombs(adjacents)
      end
    end
  end

  def seed_bombs
    bomb_squares = (1..(@size_x * @size_y)).to_a.sample(@number_of_bombs)

    board.each_index do |y|
      board[y].each_index do |x|
        if bomb_squares.include?((x + 1) + y * 9)
          board[y][x].has_bomb = true
        end
      end
    end
  end

  def do_action(action, coords)
    result = 0
    x, y = coords[0], coords[1]
    case action
    when "1"
      result = @board[y][x]
    when "2"
      @board[y][x].toggle_bomb_flag
    end
    result
  end

  def reveal(coord)
    x, y = coord

    tile = @board[y][x]

    if tile.revealed
      return :already_revealed
    elsif tile.has_bomb_flag
      return :has_bomb_flag
    else
      tile.revealed = true
    end

    if tile.adjacent_bombs == 0
      tiles = get_adjacents(coord)
      tiles.each do |tile|
        reveal(tile.pos)
      end
    end
  end

  def explore_selection(coord)
    x, y = coord[0], coord[1]

    if @board[y][x].adjacent_bombs.nil?
      adjacents = get_adjacents([x, y])
      @board[y][x].adjacent_bombs = number_of_adjacent_bombs(coords)

      if @board[y][x].adjacent_bombs == 0
        adjacents_to_explore = adjacents.reject do |adjacent|
          x, y = adjacent[0], adjacent[1]
          @board[y][x].has_bomb?
        end

        adjacents_to_explore.each do |adjacent|
          bombs = number_of_adjacent_bombs(adjacent)

        end
      end
    else
      @board[y][x].adjacent_bombs
    end

  end

  def number_of_adjacent_bombs(adjacents)
    adjacents.count(&:has_bomb?)
  end

  def toggle_bomb_flag(coord)
    x, y = coord[0], coord[1]
    tile = @board[y][x]
    tile.has_bomb_flag = !tile.has_bomb_flag
  end

  def get_adjacents(coord)
    x, y = coord[0], coord[1]

    possible_adjacents = [[1,1], [0,1], [-1,0], [-1,-1], [0, -1], [-1, 1], [1, -1], [1,0]]

    possible_array = possible_adjacents.map do |array|
      [x + array[0], y + array[1]]
    end

    adjacents_to_check = possible_array.select do |array|
      (0...@size_x).include?(array[0]) && (0...@size_y).include?(array[1])
    end

    adjacents_to_check.map do |x, y|
      @board[y][x]
    end
  end

  def to_s
    string = ""
    @board.each do |row|
      row.each do |col|
        string += col.to_s
      end
      string.strip!
      string += "\n"
    end
    string
  end
end


class Tile
  attr_accessor :display_value, :has_bomb_flag, :revealed, :adjacents, :has_bomb, :adjacent_bombs
  attr_reader :pos



  def initialize(pos, grid)
    @pos = pos  #Array pair ?  [0, 0]
    @grid =  grid #  [9, 9]
    @revealed = false
    @has_bomb = false
    @has_bomb_flag = false
    @adjacent_bombs = nil
  end

  def has_bomb?
    @has_bomb
  end

  def to_s
    if @has_bomb_flag
      "F ".colorize(:light_red)
    elsif @revealed
      @adjacent_bombs == 0 ? "  ".colorize(:background => :light_cyan) : "#{@adjacent_bombs} ".colorize(BOMB_COUNT_COLOR[@adjacent_bombs]).colorize(:background => :blue)
    else
      "  ".colorize(:light_white).colorize(:background => :light_white)
    end
  end

  BOMB_COUNT_COLOR = {
    0 => :white,
    1 => :green,
    2 => :blue,
    3 => :magenta,
    4 => :red

    # :black,
    #  :red,
    #  :green,
    #  :yellow,
    #  :blue,
    #  :magenta,
    #  :cyan,
    #  :white,
    #  :default,
    #  :light_black,
    #  :light_red,
    #  :light_green,
    #  :light_yellow,
    #  :light_blue,
    #  :light_magenta,
    #  :light_cyan,
    #  :light_white
  }

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
    input = gets.chomp
    if input == "1"
      :reveal
    elsif input == "2"
      :toggle_flag
    elsif input == "4"
      :save_game
    end
  end
end

player = Player.new("Kevin")


#game = MineSweeper.new(player)
saved_game = File.read('save1.yaml')
p saved_game[0..50]

game = YAML::load(saved_game)

game.play_game(false)