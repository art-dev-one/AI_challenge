module RubyInputValidator
  # Validator for numeric values
  # Supports minimum value, maximum value, and integer-only constraints
  class NumberValidator < Validator
    # Initialize a new number validator
    def initialize
      super
      @min = nil
      @max = nil
      @integer_only = false
    end
    
    # Set minimum allowed value
    # @param value [Numeric] minimum value allowed
    # @return [NumberValidator] self for method chaining
    def min(value)
      @min = value
      self
    end
    
    # Set maximum allowed value
    # @param value [Numeric] maximum value allowed
    # @return [NumberValidator] self for method chaining
    def max(value)
      @max = value
      self
    end
    
    # Require the number to be an integer (no decimal places)
    # @return [NumberValidator] self for method chaining
    def integer
      @integer_only = true
      self
    end
    
    protected
    
    # Perform number validation with all configured constraints
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      # Check if value is numeric
      unless value.is_a?(Numeric)
        return error("Expected number, got #{value.class}")
      end
      
      # Check integer-only constraint
      if @integer_only && !value.is_a?(Integer)
        return error("Expected integer, got #{value.class}")
      end
      
      # Check minimum value constraint
      if @min && value < @min
        return error("Number must be at least #{@min}")
      end
      
      # Check maximum value constraint
      if @max && value > @max
        return error("Number must be at most #{@max}")
      end
      
      # All validations passed
      success(value)
    end
  end
end 