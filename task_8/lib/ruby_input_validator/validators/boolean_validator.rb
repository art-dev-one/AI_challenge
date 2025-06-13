module RubyInputValidator
  # Validator for boolean values (true/false)
  # Accepts only TrueClass and FalseClass instances
  class BooleanValidator < Validator
    protected
    
    # Perform boolean validation
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      # Check if value is a boolean (true or false)
      unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
        return error("Expected boolean, got #{value.class}")
      end
      
      # Validation passed
      success(value)
    end
  end
end 