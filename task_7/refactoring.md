# Battleship Game Refactoring Journey

## Overview
This document chronicles the complete refactoring of a Battleship game from JavaScript to Ruby, applying object-oriented programming principles and design patterns.

## Phase 1: JavaScript to Ruby Conversion

### Original JavaScript Code
The original code was a procedural JavaScript implementation with:
- Global variables for game state
- Function-based architecture
- Single-file structure
- Basic battleship gameplay mechanics

### Initial Ruby Conversion
**Key Changes Made:**
- `var` declarations → Ruby variables and global variables (`$`)
- `function functionName()` → `def function_name` with `end`
- Snake_case naming convention for Ruby
- JavaScript objects → Ruby hashes with symbols
- `console.log()` → `puts`
- `readline` interface → `gets.chomp`
- `Math.random()` → `rand()`
- String concatenation → Ruby string interpolation (`"#{var}"`)

## Phase 2: Object-Oriented Refactoring

### Problems with Initial Ruby Code
- **Global Variables**: Used `$` prefixed globals everywhere
- **No Encapsulation**: All data and logic exposed
- **Procedural Style**: Functions without proper organization
- **Single Responsibility Violations**: Functions doing multiple things
- **Hard to Test**: Tightly coupled code
- **Difficult to Extend**: Adding features would require global changes

### Refactoring Strategy

#### 1. Modules Implementation

**GameConstants Module:**
```ruby
module GameConstants
  BOARD_SIZE = 10
  NUM_SHIPS = 3
  SHIP_LENGTH = 3
  WATER = '~'
  SHIP = 'S'
  HIT = 'X'
  MISS = 'O'
end
```
- Centralized all game configuration
- Easy to modify game parameters
- Constants properly scoped

**Displayable Module (Mixin):**
```ruby
module Displayable
  def print_boards(opponent_board, player_board)
    # UI rendering logic
  end
end
```
- Separated UI concerns
- Reusable across classes
- Clean separation of responsibilities

**Validatable Module (Mixin):**
```ruby
module Validatable
  def valid_coordinates?(row, col)
    # Validation logic
  end
  
  def valid_guess_format?(guess)
    # Input validation
  end
end
```
- Shared validation logic
- DRY principle applied
- Consistent validation across components

#### 2. Class Architecture

**Ship Class:**
```ruby
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
    # Hit processing logic
  end

  def sunk?
    @hits.all? { |hit| hit }
  end
end
```
- **Single Responsibility**: Manages ship state only
- **Encapsulation**: Private data with public interface
- **Clear API**: Intuitive method names

**Board Class:**
```ruby
class Board
  include Validatable
  
  attr_reader :grid, :ships

  def initialize
    @grid = Array.new(GameConstants::BOARD_SIZE) { Array.new(GameConstants::BOARD_SIZE, GameConstants::WATER) }
    @ships = []
    @guesses = []
  end

  def place_ships_randomly
    # Ship placement logic
  end

  def process_guess(guess)
    # Guess processing with validation
  end

  private

  def place_single_ship_randomly
    # Private implementation details
  end
end
```
- **Manages Grid State**: All board-related operations
- **Validation Integration**: Uses Validatable module
- **Private Methods**: Implementation details hidden
- **Clear Interface**: Public methods for game operations

**Player Hierarchy:**
```ruby
class Player
  include Validatable
  attr_reader :board

  def initialize
    @board = Board.new
    @board.place_ships_randomly
  end
end

class HumanPlayer < Player
  def make_guess
    # Human input handling
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
    # AI logic with strategy pattern
  end
end
```
- **Template Method Pattern**: Base Player class with specialized implementations
- **Strategy Pattern**: CPU uses different strategies (hunt vs target)
- **Inheritance**: Code reuse while maintaining polymorphism

**Game Controller:**
```ruby
class BattleshipGame
  include Displayable
  
  def initialize
    @human_player = HumanPlayer.new
    @cpu_player = CPUPlayer.new
  end

  def start
    puts "\nLet's play Sea Battle!"
    puts "Try to sink the #{GameConstants::NUM_SHIPS} enemy ships."
    game_loop
  end

  private

  def game_loop
    # Main game logic coordination
  end
end
```
- **Coordinator Pattern**: Orchestrates game flow
- **Dependency Management**: Creates and manages player instances
- **Clean Interface**: Simple public API

### Design Patterns Applied

1. **Strategy Pattern**: CPU AI modes (hunt/target)
2. **Template Method**: Player base class with specialized behavior
3. **Mixin Pattern**: Modules for shared functionality
4. **Single Responsibility**: Each class has one clear purpose
5. **Factory Pattern**: Board creates ships during placement

### Critical Bug Fix: CPU Ships Visibility

**Problem Identified:**
```ruby
# Original problematic code
@opponent_board = Board.new  # Empty board with no ships!
```

**Solution Implemented:**
```ruby
def display_cell(row, col, hide_ships = false)
  cell = @grid[row][col]
  # Hide ships from opponent's view unless they've been hit
  if hide_ships && cell == GameConstants::SHIP
    GameConstants::WATER
  else
    cell
  end
end
```

**Changes Made:**
- Removed separate empty opponent board
- Added `hide_ships` parameter to control ship visibility
- Used CPU's actual board with ships
- Maintained "fog of war" gameplay mechanics

## Results

### Before Refactoring
```ruby
# Global variables everywhere
$player_ships = []
$cpu_ships = []
$board = []

# Monolithic functions
def processPlayerGuess(guess)
  # 50+ lines of mixed logic
end
```

### After Refactoring
```ruby
# Clean class structure
class BattleshipGame
  def initialize
    @human_player = HumanPlayer.new
    @cpu_player = CPUPlayer.new
  end
end

# Focused responsibilities
class Ship
  def sunk?
    @hits.all? { |hit| hit }
  end
end
```

### Benefits Achieved

✅ **No Global Variables** - Everything properly encapsulated  
✅ **Modular Design** - Easy to extend and modify  
✅ **Testable Code** - Each component can be tested independently  
✅ **Readable Code** - Clear class names and method responsibilities  
✅ **Maintainable** - Changes isolated to specific classes  
✅ **Extensible** - Can easily add new player types or features  
✅ **Error Handling** - Better input validation and edge cases  
✅ **Ruby Idioms** - Follows Ruby best practices and conventions  

## Technical Improvements

### Memory Management
- Eliminated global state leakage
- Proper object lifecycle management
- Reduced coupling between components

### Code Organization
- Related functionality grouped in classes
- Clear public/private interfaces
- Logical file structure ready for separation

### Error Handling
- Input validation centralized in modules
- Graceful handling of edge cases
- Clear error messages for users

### Performance
- Efficient ship placement algorithms
- Optimized guess processing
- Reduced redundant operations

## Conclusion

The refactoring transformed a procedural JavaScript script into a well-structured, object-oriented Ruby application. The final code is:

- **More Maintainable**: Changes are localized and predictable
- **More Extensible**: New features can be added without major refactoring
- **More Testable**: Each class can be unit tested independently
- **More Readable**: Code intent is clear and self-documenting
- **More Robust**: Better error handling and validation

This refactoring demonstrates the power of applying object-oriented principles and design patterns to improve code quality, maintainability, and extensibility. 