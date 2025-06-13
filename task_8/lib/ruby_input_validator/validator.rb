module RubyInputValidator
  # Base class for all validators
  # Provides common functionality like optional fields and custom error messages
  class Validator
    # Initialize a new validator with default settings
    def initialize
      @optional = false
      @custom_message = nil
    end
    
    # Mark this validator as optional
    # Optional validators will pass validation for nil or empty string values
    # @return [Validator] self for method chaining
    def optional
      @optional = true
      self
    end
    
    # Set a custom error message for validation failures
    # @param message [String] the custom error message to use
    # @return [Validator] self for method chaining
    def with_message(message)
      @custom_message = message
      self
    end
    
    # Validate a value against this validator's rules
    # @param value [Object] the value to validate
    # @return [ValidationResult] result containing validation status, value, and errors
    def validate(value)
      # Skip validation for optional fields that are nil or empty
      return ValidationResult.new(true, nil, []) if @optional && (value.nil? || value == "")
      
      result = perform_validation(value)
      # Apply custom message if validation failed and custom message is set
      unless result.valid?
        result.errors.each { |error| error[:message] = @custom_message if @custom_message }
      end
      result
    end
    
    protected
    
    # Abstract method that subclasses must implement to perform actual validation
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    # @raise [NotImplementedError] if not implemented by subclass
    def perform_validation(value)
      raise NotImplementedError, "Subclasses must implement perform_validation"
    end
    
    # Create a validation error result
    # @param message [String] error message
    # @param path [Array] path to the field being validated (for nested objects)
    # @return [ValidationResult] failed validation result
    def error(message, path = [])
      ValidationResult.new(false, nil, [{ path: path, message: message }])
    end
    
    # Create a successful validation result
    # @param value [Object] the validated value
    # @return [ValidationResult] successful validation result
    def success(value)
      ValidationResult.new(true, value, [])
    end
  end
  
  # Result of a validation operation
  # Contains the validation status, processed value, and any errors
  class ValidationResult
    attr_reader :valid, :value, :errors
    
    # Initialize a new validation result
    # @param valid [Boolean] whether validation passed
    # @param value [Object] the validated/processed value
    # @param errors [Array<Hash>] array of error hashes with :path and :message keys
    def initialize(valid, value, errors)
      @valid = valid
      @value = value
      @errors = errors
    end
    
    # Check if validation was successful
    # @return [Boolean] true if validation passed
    def valid?
      @valid
    end
    
    # Check if validation failed
    # @return [Boolean] true if validation failed
    def invalid?
      !@valid
    end
  end
end 