# Ruby Input Validator - Main entry point
# A flexible, chainable schema validation library for Ruby
# 
# This file loads all the validator components and defines the main module

require_relative "ruby_input_validator/version"
require_relative "ruby_input_validator/validator"
require_relative "ruby_input_validator/validators/string_validator"
require_relative "ruby_input_validator/validators/number_validator"
require_relative "ruby_input_validator/validators/boolean_validator"
require_relative "ruby_input_validator/validators/date_validator"
require_relative "ruby_input_validator/validators/object_validator"
require_relative "ruby_input_validator/validators/array_validator"
require_relative "ruby_input_validator/schema"

# Main module for Ruby Input Validator
# Provides a clean, chainable API for validating data structures
module RubyInputValidator
  # Base error class for all validator-related errors
  class Error < StandardError; end
  
  # Error raised when validation fails
  class ValidationError < Error; end
end 