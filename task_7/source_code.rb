require 'io/console'

module GameConstants
  BOARD_SIZE = 10
  NUM_SHIPS = 3
  SHIP_LENGTH = 3
  WATER = '~'
  SHIP = 'S'
  HIT = 'X'
  MISS = 'O'
end

class GameExitError < StandardError
  attr_reader :exit_code
  
  def initialize(message = "Game exit requested", exit_code = 0)
    super(message)
    @exit_code = exit_code
  end
end

module Displayable
  def print_boards(opponent_board, player_board)
    puts "\n   --- OPPONENT BOARD ---          --- YOUR BOARD ---"
    header = '  '
    GameConstants::BOARD_SIZE.times { |h| header += "#{h} " }
    puts "#{header}     #{header}"
    
    GameConstants::BOARD_SIZE.times do |i|
      row_str = "#{i} "
      
      GameConstants::BOARD_SIZE.times do |j|
        row_str += "#{opponent_board.display_cell(i, j, true)} "
      end
      
      row_str += "    #{i} "
      
      GameConstants::BOARD_SIZE.times do |j|
        row_str += "#{player_board.display_cell(i, j)} "
      end
      
      puts row_str
    end
    puts "\n"
  end
end

module Validatable
  def valid_coordinates?(row, col)
    row >= 0 && row < GameConstants::BOARD_SIZE && 
    col >= 0 && col < GameConstants::BOARD_SIZE
  end

  def valid_guess_format?(guess)
    !guess.nil? && guess.length == 2 && guess.match?(/\A\d{2}\z/)
  end
end

class Ship
  attr_reader :locations, :hits

  def initialize
    @locations = []
    @hits = []
  end

  def add_location(location)
    @locations << location
    @hits << false
  end

  def hit(location)
    index = @locations.index(location)
    return false unless index
    
    @hits[index] = true
    true
  end

  def hit_at?(location)
    index = @locations.index(location)
    index && @hits[index]
  end

  def sunk?
    @hits.all? { |hit| hit }
  end

  def includes_location?(location)
    @locations.include?(location)
  end
end

class Board
  include Validatable
  
  attr_reader :grid, :ships

  def initialize
    @grid = Array.new(GameConstants::BOARD_SIZE) { Array.new(GameConstants::BOARD_SIZE, GameConstants::WATER) }
    @ships = []
    @guesses = []
  end

  def place_ships_randomly
    GameConstants::NUM_SHIPS.times do
      place_single_ship_randomly
    end
    puts "#{GameConstants::NUM_SHIPS} ships placed randomly."
  end

  def process_guess(guess)
    return false unless valid_guess_format?(guess)
    
    row, col = guess.chars.map(&:to_i)
    return false unless valid_coordinates?(row, col)
    
    location = guess
    return false if @guesses.include?(location)
    
    @guesses << location
    
    hit_ship = @ships.find { |ship| ship.includes_location?(location) }
    
    if hit_ship
      hit_ship.hit(location)
      @grid[row][col] = GameConstants::HIT
      { result: :hit, sunk: hit_ship.sunk? }
    else
      @grid[row][col] = GameConstants::MISS
      { result: :miss, sunk: false }
    end
  end

  def display_cell(row, col, hide_ships = false)
    cell = @grid[row][col]
    # Hide ships from opponent's view unless they've been hit
    if hide_ships && cell == GameConstants::SHIP
      GameConstants::WATER
    else
      cell
    end
  end

  def ships_remaining
    @ships.count { |ship| !ship.sunk? }
  end

  def already_guessed?(location)
    @guesses.include?(location)
  end

  private

  def place_single_ship_randomly
    loop do
      orientation = rand < 0.5 ? :horizontal : :vertical
      start_row, start_col = generate_start_position(orientation)
      
      if can_place_ship?(start_row, start_col, orientation)
        place_ship(start_row, start_col, orientation)
        break
      end
    end
  end

  def generate_start_position(orientation)
    if orientation == :horizontal
      [rand(GameConstants::BOARD_SIZE), rand(GameConstants::BOARD_SIZE - GameConstants::SHIP_LENGTH + 1)]
    else
      [rand(GameConstants::BOARD_SIZE - GameConstants::SHIP_LENGTH + 1), rand(GameConstants::BOARD_SIZE)]
    end
  end

  def can_place_ship?(start_row, start_col, orientation)
    GameConstants::SHIP_LENGTH.times do |i|
      row = orientation == :horizontal ? start_row : start_row + i
      col = orientation == :horizontal ? start_col + i : start_col
      
      return false if @grid[row][col] != GameConstants::WATER
    end
    true
  end

  def place_ship(start_row, start_col, orientation)
    ship = Ship.new
    
    GameConstants::SHIP_LENGTH.times do |i|
      row = orientation == :horizontal ? start_row : start_row + i
      col = orientation == :horizontal ? start_col + i : start_col
      
      location = "#{row}#{col}"
      ship.add_location(location)
      @grid[row][col] = GameConstants::SHIP
    end
    
    @ships << ship
  end
end

class Player
  include Validatable
  
  attr_reader :board

  def initialize
    @board = Board.new
    @board.place_ships_randomly
  end

  def ships_remaining
    @board.ships_remaining
  end
end

class HumanPlayer < Player
  def make_guess
    loop do
      print 'Enter your guess (e.g., 00): '
      input = gets
      
      # Handle nil input (EOF or no input stream)
      if input.nil?
        puts "\nNo input received. Exiting game."
        raise GameExitError.new("No input received", 0)
      end
      
      guess = input.chomp
      
      unless valid_guess_format?(guess)
        puts 'Oops, input must be exactly two digits (e.g., 00, 34, 98).'
        next
      end
      
      row, col = guess.chars.map(&:to_i)
      unless valid_coordinates?(row, col)
        puts "Oops, please enter valid row and column numbers between 0 and #{GameConstants::BOARD_SIZE - 1}."
        next
      end
      
      return guess
    end
  end
end

class CPUPlayer < Player
  def initialize
    super
    @mode = :hunt
    @target_queue = []
    @guesses = []
  end

  def make_guess
    guess = if @mode == :target && !@target_queue.empty?
              target_guess
            else
              hunt_guess
            end
    
    @guesses << guess
    puts "CPU targets: #{guess}" if @mode == :target
    guess
  end

  def process_guess_result(guess, result)
    row, col = guess.chars.map(&:to_i)
    
    if result[:result] == :hit
      puts "CPU HIT at #{guess}!"
      
      if result[:sunk]
        puts 'CPU sunk your battleship!'
        @mode = :hunt
        @target_queue.clear
      else
        @mode = :target
        add_adjacent_targets(row, col)
      end
    else
      puts "CPU MISS at #{guess}."
      @mode = :hunt if @mode == :target && @target_queue.empty?
    end
  end

  private

  def target_guess
    loop do
      guess = @target_queue.shift
      return guess unless @guesses.include?(guess)
      @mode = :hunt if @target_queue.empty?
    end
  end

  def hunt_guess
    @mode = :hunt
    loop do
      row = rand(GameConstants::BOARD_SIZE)
      col = rand(GameConstants::BOARD_SIZE)
      guess = "#{row}#{col}"
      return guess unless @guesses.include?(guess)
    end
  end

  def add_adjacent_targets(row, col)
    adjacent_positions = [
      [row - 1, col], [row + 1, col],
      [row, col - 1], [row, col + 1]
    ]
    
    adjacent_positions.each do |adj_row, adj_col|
      if valid_coordinates?(adj_row, adj_col)
        guess = "#{adj_row}#{adj_col}"
        @target_queue << guess unless @guesses.include?(guess) || @target_queue.include?(guess)
      end
    end
  end
end

class BattleshipGame
  include Displayable
  
  def initialize
    @human_player = HumanPlayer.new
    @cpu_player = CPUPlayer.new
  end

  def start
    puts "\nLet's play Sea Battle!"
    puts "Try to sink the #{GameConstants::NUM_SHIPS} enemy ships."
    begin
      game_loop
    rescue GameExitError => e
      puts e.message unless e.message == "Game exit requested"
      exit(e.exit_code)
    end
  end

  private

  def game_loop
    loop do
      return declare_winner if game_over?
      
      print_boards(@cpu_player.board, @human_player.board)
      
      # Human player's turn
      human_guess = @human_player.make_guess
      
      if @cpu_player.board.already_guessed?(human_guess)
        puts 'You already guessed that location!'
        next
      end
      
      result = @cpu_player.board.process_guess(human_guess)
      
      display_human_result(result)
      return declare_winner if game_over?
      
      # CPU player's turn
      puts "\n--- CPU's Turn ---"
      cpu_guess = @cpu_player.make_guess
      cpu_result = @human_player.board.process_guess(cpu_guess)
      @cpu_player.process_guess_result(cpu_guess, cpu_result)
      
      return declare_winner if game_over?
    end
  end

  def display_human_result(result)
    if result[:result] == :hit
      puts 'PLAYER HIT!'
      puts 'You sunk an enemy battleship!' if result[:sunk]
    else
      puts 'PLAYER MISS.'
    end
  end

  def game_over?
    @human_player.ships_remaining == 0 || @cpu_player.ships_remaining == 0
  end

  def declare_winner
    print_boards(@cpu_player.board, @human_player.board)
    
    if @cpu_player.ships_remaining == 0
      puts "\n*** CONGRATULATIONS! You sunk all enemy battleships! ***"
    else
      puts "\n*** GAME OVER! The CPU sunk all your battleships! ***"
    end
  end
end

# Start the game only if this file is run directly (not required by tests)
if __FILE__ == $0
  BattleshipGame.new.start
end 