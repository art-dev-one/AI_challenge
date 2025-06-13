module RubyInputValidator
  # Validator for string values
  # Supports minimum length, maximum length, and pattern matching constraints
  class StringValidator < Validator
    # Initialize a new string validator
    def initialize
      super
      @min_length = nil
      @max_length = nil
      @pattern = nil
    end
    
    # Set minimum required length for the string
    # @param length [Integer] minimum number of characters required
    # @return [StringValidator] self for method chaining
    def min_length(length)
      @min_length = length
      self
    end
    
    # Set maximum allowed length for the string
    # @param length [Integer] maximum number of characters allowed
    # @return [StringValidator] self for method chaining
    def max_length(length)
      @max_length = length
      self
    end
    
    # Set a regular expression pattern that the string must match
    # @param regex [Regexp] regular expression pattern to match against
    # @return [StringValidator] self for method chaining
    def pattern(regex)
      @pattern = regex
      self
    end
    
    protected
    
    # Perform string validation with all configured constraints
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      # Check if value is a string
      unless value.is_a?(String)
        return error("Expected string, got #{value.class}")
      end
      
      # Check minimum length constraint
      if @min_length && value.length < @min_length
        return error("String must be at least #{@min_length} characters long")
      end
      
      # Check maximum length constraint
      if @max_length && value.length > @max_length
        return error("String must be at most #{@max_length} characters long")
      end
      
      # Check pattern matching constraint
      if @pattern && !@pattern.match?(value)
        return error("String does not match required pattern")
      end
      
      # All validations passed
      success(value)
    end
  end
end 