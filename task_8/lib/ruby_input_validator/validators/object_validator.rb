module RubyInputValidator
  # Validator for hash/object structures
  # Validates each field in the hash using provided field validators
  class ObjectValidator < Validator
    # Initialize a new object validator
    # @param schema [Hash] hash mapping field names to validators
    def initialize(schema = {})
      super()
      @schema = schema
    end
    
    protected
    
    # Perform object validation with the configured schema
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      # Check if value is a hash (object)
      unless value.is_a?(Hash)
        return error("Expected object (Hash), got #{value.class}")
      end
      
      validated_object = {}
      errors = []
      
      # Validate each field in the schema
      @schema.each do |key, validator|
        # Look for the field value using various key formats (symbol, string)
        field_value = value[key] || value[key.to_s] || value[key.to_sym]
        result = validator.validate(field_value)
        
        if result.valid?
          # Store the validated value
          validated_object[key] = result.value
        else
          # Collect errors with proper path information
          result.errors.each do |error|
            errors << {
              path: [key] + error[:path],
              message: error[:message]
            }
          end
        end
      end
      
      # Return result based on whether any validation errors occurred
      if errors.any?
        ValidationResult.new(false, nil, errors)
      else
        success(validated_object)
      end
    end
  end
end 