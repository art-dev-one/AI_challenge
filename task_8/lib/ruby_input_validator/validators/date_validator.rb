require 'date'

module RubyInputValidator
  # Validator for date values
  # Accepts Date, Time, DateTime objects and parseable date strings
  # Supports before and after constraints
  class DateValidator < Validator
    # Initialize a new date validator
    def initialize
      super
      @after = nil
      @before = nil
    end
    
    # Set a date that the validated date must be after
    # @param date [Date, Time, DateTime] the date to compare against
    # @return [DateValidator] self for method chaining
    def after(date)
      @after = date
      self
    end
    
    # Set a date that the validated date must be before
    # @param date [Date, Time, DateTime] the date to compare against
    # @return [DateValidator] self for method chaining
    def before(date)
      @before = date
      self
    end
    
    protected
    
    # Perform date validation with all configured constraints
    # @param value [Object] the value to validate
    # @return [ValidationResult] validation result
    def perform_validation(value)
      parsed_date = nil
      
      # Try to parse the date from various formats
      if value.is_a?(Date) || value.is_a?(Time) || value.is_a?(DateTime)
        parsed_date = value.to_date
      elsif value.is_a?(String)
        begin
          parsed_date = Date.parse(value)
        rescue ArgumentError
          return error("Invalid date format")
        end
      else
        return error("Expected date, got #{value.class}")
      end
      
      # Check after constraint
      if @after && parsed_date <= @after
        return error("Date must be after #{@after}")
      end
      
      # Check before constraint
      if @before && parsed_date >= @before
        return error("Date must be before #{@before}")
      end
      
      # All validations passed, return the parsed date
      success(parsed_date)
    end
  end
end 