module RubyInputValidator
  # Validator for arrays of items
  # Validates each item in the array using a provided item validator
  # Supports minimum and maximum item count constraints
  class ArrayValidator < Validator
    # Initialize a new array validator
    # @param item_validator [Validator] validator to apply to each array item
    def initialize(item_validator)
      super()
      @item_validator = item_validator
      @min_items = nil
      @max_items = nil
    end
    
    # Set minimum required number of items in the array
    # @param count [Integer] minimum number of items required
    # @return [ArrayValidator] self for method chaining
    def min_items(count)
      @min_items = count
      self
    end
    
    # Set maximum allowed number of items in the array
    # @param count [Integer] maximum number of items allowed
    # @return [ArrayValidator] self for method chaining
    def max_items(count)
      @max_items = count
      self
    end
    
    protected
    
    # Perform array validation with all configured constraints
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      # Check if value is an array
      unless value.is_a?(Array)
        return error("Expected array, got #{value.class}")
      end
      
      # Check minimum items constraint
      if @min_items && value.length < @min_items
        return error("Array must have at least #{@min_items} items")
      end
      
      # Check maximum items constraint
      if @max_items && value.length > @max_items
        return error("Array must have at most #{@max_items} items")
      end
      
      validated_items = []
      errors = []
      
      # Validate each item in the array
      value.each_with_index do |item, index|
        result = @item_validator.validate(item)
        if result.valid?
          validated_items << result.value
        else
          # Collect errors with proper path information
          result.errors.each do |error|
            errors << {
              path: [index] + error[:path],
              message: error[:message]
            }
          end
        end
      end
      
      # Return result based on whether any validation errors occurred
      if errors.any?
        ValidationResult.new(false, nil, errors)
      else
        success(validated_items)
      end
    end
  end
end 