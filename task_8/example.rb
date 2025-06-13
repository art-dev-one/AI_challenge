#!/usr/bin/env ruby

require_relative 'lib/ruby_input_validator'

# Define a complex schema
address_schema = RubyInputValidator::Schema.object({
  street: RubyInputValidator::Schema.string,
  city: RubyInputValidator::Schema.string,
  postal_code: RubyInputValidator::Schema.string.pattern(/^\d{5}$/).with_message('Postal code must be 5 digits'),
  country: RubyInputValidator::Schema.string
})

user_schema = RubyInputValidator::Schema.object({
  id: RubyInputValidator::Schema.string.with_message('ID must be a string'),
  name: RubyInputValidator::Schema.string.min_length(2).max_length(50),
  email: RubyInputValidator::Schema.string.pattern(/^[^\s@]+@[^\s@]+\.[^\s@]+$/),
  age: RubyInputValidator::Schema.number.optional,
  is_active: RubyInputValidator::Schema.boolean,
  tags: RubyInputValidator::Schema.array(RubyInputValidator::Schema.string),
  address: address_schema.optional,
  metadata: RubyInputValidator::Schema.object({}).optional
})

# Validate data
user_data = {
  id: "12345",
  name: "John Doe",
  email: "john@example.com",
  is_active: true,
  tags: ["developer", "designer"],
  address: {
    street: "123 Main St",
    city: "Anytown",
    postal_code: "12345",
    country: "USA"
  }
}

puts "=== Ruby Input Validator Example ==="
puts
puts "User Data:"
p user_data
puts

result = user_schema.validate(user_data)

if result.valid?
  puts "✅ Validation passed!"
  puts "Validated data:"
  p result.value
else
  puts "❌ Validation failed!"
  puts "Errors:"
  result.errors.each do |error|
    path = error[:path].join('.')
    path = 'root' if path.empty?
    puts "  - #{path}: #{error[:message]}"
  end
end

puts
puts "=== Testing Invalid Data ==="
puts

invalid_data = {
  id: 123,  # Should be string
  name: "J", # Too short
  email: "invalid-email",
  is_active: "yes", # Should be boolean
  tags: "not-an-array",
  address: {
    postal_code: "1234" # Should be 5 digits
  }
}

puts "Invalid Data:"
p invalid_data
puts

invalid_result = user_schema.validate(invalid_data)
puts "❌ Validation failed as expected!"
puts "Errors:"
invalid_result.errors.each do |error|
  path = error[:path].join('.')
  path = 'root' if path.empty?
  puts "  - #{path}: #{error[:message]}"
end 