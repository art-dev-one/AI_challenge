module RubyInputValidator
  # Main API for creating validators
  # Provides factory methods for all validator types
  class Schema
    # Create a string validator
    # @return [StringValidator] new string validator instance
    def self.string
      StringValidator.new
    end
    
    # Create a number validator
    # @return [NumberValidator] new number validator instance
    def self.number
      NumberValidator.new
    end
    
    # Create a boolean validator
    # @return [BooleanValidator] new boolean validator instance
    def self.boolean
      BooleanValidator.new
    end
    
    # Create a date validator
    # @return [DateValidator] new date validator instance
    def self.date
      DateValidator.new
    end
    
    # Create an object validator with optional schema
    # @param schema [Hash] hash mapping field names to validators
    # @return [ObjectValidator] new object validator instance
    def self.object(schema = {})
      ObjectValidator.new(schema)
    end
    
    # Create an array validator for validating arrays of items
    # @param item_validator [Validator] validator to apply to each array item
    # @return [ArrayValidator] new array validator instance
    def self.array(item_validator)
      ArrayValidator.new(item_validator)
    end
  end
end 