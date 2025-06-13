require 'rspec'
require_relative 'source_code'

RSpec.describe 'Battleship Game' do
  describe GameExitError do
    it 'initializes with default values' do
      error = GameExitError.new
      expect(error.message).to eq("Game exit requested")
      expect(error.exit_code).to eq(0)
    end

    it 'initializes with custom values' do
      error = GameExitError.new("Custom message", 1)
      expect(error.message).to eq("Custom message")
      expect(error.exit_code).to eq(1)
    end
  end

  describe GameConstants do
    it 'defines correct board size' do
      expect(GameConstants::BOARD_SIZE).to eq(10)
    end

    it 'defines correct number of ships' do
      expect(GameConstants::NUM_SHIPS).to eq(3)
    end

    it 'defines correct ship length' do
      expect(GameConstants::SHIP_LENGTH).to eq(3)
    end

    it 'defines correct board symbols' do
      expect(GameConstants::WATER).to eq('~')
      expect(GameConstants::SHIP).to eq('S')
      expect(GameConstants::HIT).to eq('X')
      expect(GameConstants::MISS).to eq('O')
    end
  end

  describe Validatable do
    let(:validatable_class) do
      Class.new do
        include Validatable
      end
    end
    let(:validator) { validatable_class.new }

    describe '#valid_coordinates?' do
      it 'returns true for valid coordinates' do
        expect(validator.valid_coordinates?(0, 0)).to be true
        expect(validator.valid_coordinates?(5, 5)).to be true
        expect(validator.valid_coordinates?(9, 9)).to be true
      end

      it 'returns false for invalid coordinates' do
        expect(validator.valid_coordinates?(-1, 0)).to be false
        expect(validator.valid_coordinates?(0, -1)).to be false
        expect(validator.valid_coordinates?(10, 0)).to be false
        expect(validator.valid_coordinates?(0, 10)).to be false
        expect(validator.valid_coordinates?(15, 15)).to be false
      end
    end

    describe '#valid_guess_format?' do
      it 'returns true for valid guess format' do
        expect(validator.valid_guess_format?('00')).to be true
        expect(validator.valid_guess_format?('12')).to be true
        expect(validator.valid_guess_format?('99')).to be true
      end

      it 'returns false for invalid guess format' do
        expect(validator.valid_guess_format?(nil)).to be false
        expect(validator.valid_guess_format?('')).to be false
        expect(validator.valid_guess_format?('0')).to be false
        expect(validator.valid_guess_format?('000')).to be false
        expect(validator.valid_guess_format?('ab')).to be false
        expect(validator.valid_guess_format?('1a')).to be false
      end
    end
  end

  describe Displayable do
    let(:displayable_class) do
      Class.new do
        include Displayable
      end
    end
    let(:displayer) { displayable_class.new }
    let(:board1) { instance_double('Board') }
    let(:board2) { instance_double('Board') }

    describe '#print_boards' do
      before do
        allow(board1).to receive(:display_cell).and_return('~')
        allow(board2).to receive(:display_cell).and_return('S')
      end

      it 'prints both boards side by side' do
        expect { displayer.print_boards(board1, board2) }.to output(/OPPONENT BOARD.*YOUR BOARD/).to_stdout
      end

      it 'includes coordinate headers' do
        expect { displayer.print_boards(board1, board2) }.to output(/0 1 2 3 4 5 6 7 8 9/).to_stdout
      end
    end
  end

  describe Ship do
    let(:ship) { Ship.new }

    describe '#initialize' do
      it 'initializes with empty locations and hits arrays' do
        expect(ship.locations).to be_empty
        expect(ship.hits).to be_empty
      end
    end

    describe '#add_location' do
      it 'adds a location to the ship' do
        ship.add_location('00')
        expect(ship.locations).to include('00')
        expect(ship.hits).to include(false)
      end

      it 'adds multiple locations' do
        ship.add_location('00')
        ship.add_location('01')
        ship.add_location('02')
        expect(ship.locations).to eq(['00', '01', '02'])
        expect(ship.hits).to eq([false, false, false])
      end
    end

    describe '#hit' do
      before do
        ship.add_location('00')
        ship.add_location('01')
        ship.add_location('02')
      end

      it 'returns true and marks hit when location exists' do
        expect(ship.hit('01')).to be true
        expect(ship.hits[1]).to be true
      end

      it 'returns false when location does not exist' do
        expect(ship.hit('99')).to be false
      end

      it 'does not affect other locations' do
        ship.hit('01')
        expect(ship.hits[0]).to be false
        expect(ship.hits[2]).to be false
      end
    end

    describe '#hit_at?' do
      before do
        ship.add_location('00')
        ship.add_location('01')
        ship.hit('01')
      end

      it 'returns true for hit locations' do
        expect(ship.hit_at?('01')).to be true
      end

      it 'returns false for unhit locations' do
        expect(ship.hit_at?('00')).to be false
      end

      it 'returns nil for non-existent locations' do
        expect(ship.hit_at?('99')).to be_nil
      end
    end

    describe '#sunk?' do
      before do
        ship.add_location('00')
        ship.add_location('01')
        ship.add_location('02')
      end

      it 'returns false when no hits' do
        expect(ship.sunk?).to be false
      end

      it 'returns false when partially hit' do
        ship.hit('00')
        ship.hit('01')
        expect(ship.sunk?).to be false
      end

      it 'returns true when all locations hit' do
        ship.hit('00')
        ship.hit('01')
        ship.hit('02')
        expect(ship.sunk?).to be true
      end
    end

    describe '#includes_location?' do
      before do
        ship.add_location('00')
        ship.add_location('01')
      end

      it 'returns true for included locations' do
        expect(ship.includes_location?('00')).to be true
        expect(ship.includes_location?('01')).to be true
      end

      it 'returns false for non-included locations' do
        expect(ship.includes_location?('99')).to be false
      end
    end
  end

  describe Board do
    let(:board) { Board.new }

    describe '#initialize' do
      it 'creates a grid filled with water' do
        expect(board.grid.size).to eq(GameConstants::BOARD_SIZE)
        expect(board.grid[0].size).to eq(GameConstants::BOARD_SIZE)
        expect(board.grid[0][0]).to eq(GameConstants::WATER)
      end

      it 'initializes empty ships array' do
        expect(board.ships).to be_empty
      end
    end

    describe '#place_ships_randomly' do
      it 'places the correct number of ships' do
        board.place_ships_randomly
        expect(board.ships.size).to eq(GameConstants::NUM_SHIPS)
      end

      it 'places ships with correct length' do
        board.place_ships_randomly
        board.ships.each do |ship|
          expect(ship.locations.size).to eq(GameConstants::SHIP_LENGTH)
        end
      end

      it 'places ships on the grid' do
        board.place_ships_randomly
        ship_cells = board.grid.flatten.count { |cell| cell == GameConstants::SHIP }
        expect(ship_cells).to eq(GameConstants::NUM_SHIPS * GameConstants::SHIP_LENGTH)
      end
    end

    describe '#process_guess' do
      before do
        board.place_ships_randomly
      end

      context 'with invalid guess format' do
        it 'returns false for invalid format' do
          expect(board.process_guess('abc')).to be false
          expect(board.process_guess('1')).to be false
          expect(board.process_guess(nil)).to be false
        end
      end

      context 'with invalid format' do
        it 'returns false for invalid guess formats' do
          expect(board.process_guess('AA')).to be false  # Invalid format (letters)
          expect(board.process_guess('1')).to be false   # Invalid format (too short)
          expect(board.process_guess('abc')).to be false # Invalid format (letters)
          expect(board.process_guess('123')).to be false # Invalid format (too long)
          expect(board.process_guess('')).to be false    # Invalid format (empty)
        end
      end

      context 'with valid guess' do
        it 'accepts corner coordinates' do
          expect(board.process_guess('00')).not_to be false  # Top-left corner
          expect(board.process_guess('99')).not_to be false  # Bottom-right corner
        end

        it 'processes miss correctly' do
          # Find an empty spot
          empty_spot = nil
          10.times do |row|
            10.times do |col|
              if board.grid[row][col] == GameConstants::WATER
                empty_spot = "#{row}#{col}"
                break
              end
            end
            break if empty_spot
          end
          
          result = board.process_guess(empty_spot)
          expect(result[:result]).to eq(:miss)
          expect(result[:sunk]).to be false
        end

        it 'processes hit correctly' do
          # Find a ship spot
          ship_spot = nil
          10.times do |row|
            10.times do |col|
              if board.grid[row][col] == GameConstants::SHIP
                ship_spot = "#{row}#{col}"
                break
              end
            end
            break if ship_spot
          end
          
          result = board.process_guess(ship_spot)
          expect(result[:result]).to eq(:hit)
        end

        it 'prevents duplicate guesses' do
          result1 = board.process_guess('00')
          result2 = board.process_guess('00')
          expect(result2).to be false
        end
      end
    end

    describe '#display_cell' do
      it 'returns the cell content without hiding' do
        board.grid[0][0] = GameConstants::SHIP
        expect(board.display_cell(0, 0)).to eq(GameConstants::SHIP)
      end

      it 'hides ships when hide_ships is true' do
        board.grid[0][0] = GameConstants::SHIP
        expect(board.display_cell(0, 0, true)).to eq(GameConstants::WATER)
      end

      it 'shows hits even when hide_ships is true' do
        board.grid[0][0] = GameConstants::HIT
        expect(board.display_cell(0, 0, true)).to eq(GameConstants::HIT)
      end
    end

    describe '#ships_remaining' do
      before do
        board.place_ships_randomly
      end

      it 'returns correct count of unsunk ships' do
        expect(board.ships_remaining).to eq(GameConstants::NUM_SHIPS)
      end

      it 'decreases when ships are sunk' do
        # Sink one ship
        ship = board.ships.first
        ship.locations.each { |location| ship.hit(location) }
        expect(board.ships_remaining).to eq(GameConstants::NUM_SHIPS - 1)
      end
    end

    describe '#already_guessed?' do
      it 'returns false for new locations' do
        expect(board.already_guessed?('00')).to be false
      end

      it 'returns true for previously guessed locations' do
        board.process_guess('00')
        expect(board.already_guessed?('00')).to be true
      end
    end
  end

  describe Player do
    let(:player) { Player.new }

    describe '#initialize' do
      it 'creates a board with ships' do
        expect(player.board).to be_a(Board)
        expect(player.board.ships.size).to eq(GameConstants::NUM_SHIPS)
      end
    end

    describe '#ships_remaining' do
      it 'returns the number of ships remaining' do
        expect(player.ships_remaining).to eq(GameConstants::NUM_SHIPS)
      end
    end
  end

  describe HumanPlayer do
    let(:human_player) { HumanPlayer.new }

    describe '#make_guess' do
      it 'validates input and returns valid guess' do
        allow(human_player).to receive(:gets).and_return("00\n")
        expect(human_player.make_guess).to eq('00')
      end

      it 'prompts again for invalid input' do
        allow(human_player).to receive(:gets).and_return("invalid\n", "00\n")
        expect(human_player).to receive(:puts).with('Oops, input must be exactly two digits (e.g., 00, 34, 98).')
        expect(human_player.make_guess).to eq('00')
      end

      it 'prompts again for out of bounds coordinates' do
        allow(human_player).to receive(:gets).and_return("AA\n", "00\n")
        expect(human_player).to receive(:puts).with('Oops, input must be exactly two digits (e.g., 00, 34, 98).')
        expect(human_player.make_guess).to eq('00')
      end

      it 'handles nil input gracefully' do
        allow(human_player).to receive(:gets).and_return(nil)
        expect(human_player).to receive(:puts).with("\nNo input received. Exiting game.")
        expect { human_player.make_guess }.to raise_error(GameExitError, "No input received")
      end
    end
  end

  describe CPUPlayer do
    let(:cpu_player) { CPUPlayer.new }

    describe '#initialize' do
      it 'initializes with hunt mode' do
        expect(cpu_player.instance_variable_get(:@mode)).to eq(:hunt)
      end

      it 'initializes with empty target queue' do
        expect(cpu_player.instance_variable_get(:@target_queue)).to be_empty
      end

      it 'initializes with empty guesses' do
        expect(cpu_player.instance_variable_get(:@guesses)).to be_empty
      end
    end

    describe '#make_guess' do
      it 'returns a valid coordinate string' do
        guess = cpu_player.make_guess
        expect(guess).to match(/\A\d{2}\z/)
      end

      it 'does not repeat guesses' do
        guesses = []
        10.times do
          guess = cpu_player.make_guess
          expect(guesses).not_to include(guess)
          guesses << guess
        end
      end

      context 'in hunt mode' do
        it 'makes random guesses' do
          allow(cpu_player).to receive(:rand).and_return(0, 1)
          expect(cpu_player.make_guess).to eq('01')
        end
      end

      context 'in target mode' do
        before do
          cpu_player.instance_variable_set(:@mode, :target)
          cpu_player.instance_variable_set(:@target_queue, ['12'])
        end

        it 'uses target queue' do
          expect(cpu_player.make_guess).to eq('12')
        end
      end
    end

    describe '#process_guess_result' do
      context 'when hit but not sunk' do
        let(:result) { { result: :hit, sunk: false } }

        it 'switches to target mode and adds adjacent positions' do
          cpu_player.process_guess_result('22', result)
          expect(cpu_player.instance_variable_get(:@mode)).to eq(:target)
          target_queue = cpu_player.instance_variable_get(:@target_queue)
          expect(target_queue).to include('12', '32', '21', '23')
        end
      end

      context 'when hit and sunk' do
        let(:result) { { result: :hit, sunk: true } }

        it 'switches back to hunt mode and clears target queue' do
          cpu_player.instance_variable_set(:@mode, :target)
          cpu_player.instance_variable_set(:@target_queue, ['12', '34'])
          
          cpu_player.process_guess_result('22', result)
          expect(cpu_player.instance_variable_get(:@mode)).to eq(:hunt)
          expect(cpu_player.instance_variable_get(:@target_queue)).to be_empty
        end
      end

      context 'when miss' do
        let(:result) { { result: :miss, sunk: false } }

        it 'switches to hunt mode if target queue is empty' do
          cpu_player.instance_variable_set(:@mode, :target)
          cpu_player.instance_variable_set(:@target_queue, [])
          
          cpu_player.process_guess_result('22', result)
          expect(cpu_player.instance_variable_get(:@mode)).to eq(:hunt)
        end
      end
    end
  end

  describe BattleshipGame do
    let(:game) { BattleshipGame.new }
    let(:human_player) { instance_double('HumanPlayer') }
    let(:cpu_player) { instance_double('CPUPlayer') }
    let(:human_board) { instance_double('Board') }
    let(:cpu_board) { instance_double('Board') }

    before do
      allow(HumanPlayer).to receive(:new).and_return(human_player)
      allow(CPUPlayer).to receive(:new).and_return(cpu_player)
      allow(human_player).to receive(:board).and_return(human_board)
      allow(cpu_player).to receive(:board).and_return(cpu_board)
      allow(human_player).to receive(:ships_remaining).and_return(3)
      allow(cpu_player).to receive(:ships_remaining).and_return(3)
    end

    describe '#initialize' do
      it 'creates human and CPU players' do
        expect(HumanPlayer).to receive(:new)
        expect(CPUPlayer).to receive(:new)
        BattleshipGame.new
      end
    end

    describe '#start' do
      it 'displays welcome message and starts game loop' do
        allow(game).to receive(:game_loop)
        expect { game.start }.to output(/Let's play Sea Battle!/).to_stdout
      end

      it 'handles GameExitError gracefully' do
        allow(game).to receive(:game_loop).and_raise(GameExitError.new("Test exit", 0))
        allow(game).to receive(:exit).with(0)
        expect { game.start }.to output(/Test exit/).to_stdout
      end
    end

    describe 'game_over?' do
      it 'returns true when human has no ships' do
        allow(human_player).to receive(:ships_remaining).and_return(0)
        allow(cpu_player).to receive(:ships_remaining).and_return(2)
        expect(game.send(:game_over?)).to be true
      end

      it 'returns true when CPU has no ships' do
        allow(human_player).to receive(:ships_remaining).and_return(2)
        allow(cpu_player).to receive(:ships_remaining).and_return(0)
        expect(game.send(:game_over?)).to be true
      end

      it 'returns false when both have ships' do
        allow(human_player).to receive(:ships_remaining).and_return(2)
        allow(cpu_player).to receive(:ships_remaining).and_return(2)
        expect(game.send(:game_over?)).to be false
      end
    end

    describe 'declare_winner' do
      before do
        allow(game).to receive(:print_boards)
      end

      it 'declares human winner when CPU has no ships' do
        allow(cpu_player).to receive(:ships_remaining).and_return(0)
        expect { game.send(:declare_winner) }.to output(/CONGRATULATIONS/).to_stdout
      end

      it 'declares CPU winner when human has no ships' do
        allow(cpu_player).to receive(:ships_remaining).and_return(2)
        allow(human_player).to receive(:ships_remaining).and_return(0)
        expect { game.send(:declare_winner) }.to output(/GAME OVER/).to_stdout
      end
    end
  end

  # Integration Tests
  describe 'Integration Tests' do
    describe 'Complete Ship Lifecycle' do
      let(:board) { Board.new }
      let(:ship) { Ship.new }

      it 'can place, hit, and sink a ship' do
        # Manually place a ship
        ship.add_location('00')
        ship.add_location('01')
        ship.add_location('02')
        board.ships << ship
        
        # Place ship on grid
        board.grid[0][0] = GameConstants::SHIP
        board.grid[0][1] = GameConstants::SHIP
        board.grid[0][2] = GameConstants::SHIP

        # Hit the ship
        result1 = board.process_guess('00')
        expect(result1[:result]).to eq(:hit)
        expect(result1[:sunk]).to be false

        result2 = board.process_guess('01')
        expect(result2[:result]).to eq(:hit)
        expect(result2[:sunk]).to be false

        result3 = board.process_guess('02')
        expect(result3[:result]).to eq(:hit)
        expect(result3[:sunk]).to be true

        # Verify ship is sunk
        expect(ship.sunk?).to be true
        expect(board.ships_remaining).to eq(0)
      end
    end

    describe 'Game Flow' do
      it 'can play a complete game turn' do
        game = BattleshipGame.new
        
        # Mock human input with proper newline
        allow_any_instance_of(HumanPlayer).to receive(:gets).and_return("00\n")
        
        # Mock game over condition
        allow(game).to receive(:game_over?).and_return(false, true)
        allow(game).to receive(:declare_winner)
        allow(game).to receive(:print_boards)
        
        # Should not raise any errors (other than SystemExit from mocked exit)
        expect { game.start }.not_to raise_error
      end
    end
  end

  # Edge Cases and Error Handling
  describe 'Edge Cases' do
    describe 'Board boundary conditions' do
      let(:board) { Board.new }

      it 'handles corner coordinates correctly' do
        expect(board.process_guess('00')).not_to be_nil
        expect(board.process_guess('99')).not_to be_nil
      end

      it 'rejects out-of-bounds coordinates' do
        expect(board.process_guess('AA')).to be false
        expect(board.process_guess('1')).to be false
        expect(board.process_guess('100')).to be false
      end
    end

    describe 'Ship placement edge cases' do
      let(:board) { Board.new }

      it 'places ships without collision' do
        board.place_ships_randomly
        
        ship_positions = []
        board.ships.each do |ship|
          ship_positions.concat(ship.locations)
        end
        
        # No duplicate positions
        expect(ship_positions.uniq.size).to eq(ship_positions.size)
      end
    end

    describe 'CPU AI edge cases' do
      let(:cpu) { CPUPlayer.new }

      it 'handles empty target queue gracefully' do
        cpu.instance_variable_set(:@mode, :target)
        cpu.instance_variable_set(:@target_queue, [])
        
        # Should not crash and should switch to hunt mode
        guess = cpu.make_guess
        expect(guess).to match(/\A\d{2}\z/)
        expect(cpu.instance_variable_get(:@mode)).to eq(:hunt)
      end

      it 'handles board edge targets correctly' do
        # Test hitting at board edges
        result = { result: :hit, sunk: false }
        
        # Corner position
        cpu.process_guess_result('00', result)
        target_queue = cpu.instance_variable_get(:@target_queue)
        
        # Should only include valid adjacent positions
        target_queue.each do |target|
          row, col = target.chars.map(&:to_i)
          expect(row).to be_between(0, 9)
          expect(col).to be_between(0, 9)
        end
      end
    end
  end
end 