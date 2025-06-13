# Ruby Input Validator

A flexible, chainable schema validation library for Ruby, inspired by modern validation libraries. Ruby Input Validator provides a clean API for validating complex data structures with custom error messages and nested validation rules.

## Features

- 🔗 **Chainable API** - Fluent interface for building complex validations
- 📝 **Custom Error Messages** - Set custom messages for validation failures
- 🏗️ **Schema Composition** - Build complex schemas from simple validators
- 🎯 **Type Safety** - Validates data types and structures
- 🔄 **Optional Fields** - Mark fields as optional with `.optional`
- 📊 **Detailed Error Reporting** - Get precise error paths and messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_input_validator'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruby_input_validator

## Usage

### Basic Validators

```ruby
require 'ruby_input_validator'

# String validation
name_validator = RubyInputValidator::Schema.string.min_length(2).max_length(50)
email_validator = RubyInputValidator::Schema.string.pattern(/\A[^@\s]+@[^@\s]+\z/)

# Number validation
age_validator = RubyInputValidator::Schema.number.min(0).max(120)
price_validator = RubyInputValidator::Schema.number.min(0)

# Boolean validation
active_validator = RubyInputValidator::Schema.boolean

# Date validation
birthday_validator = RubyInputValidator::Schema.date.before(Date.today)
```

### Object Schemas

```ruby
# Define a user schema
user_schema = RubyInputValidator::Schema.object({
  name: RubyInputValidator::Schema.string.min_length(2),
  email: RubyInputValidator::Schema.string.pattern(/\A[^@\s]+@[^@\s]+\z/),
  age: RubyInputValidator::Schema.number.min(0).optional,
  is_active: RubyInputValidator::Schema.boolean
})

# Validate data
user_data = {
  name: "John Doe",
  email: "john@example.com", 
  is_active: true
}

result = user_schema.validate(user_data)

if result.valid?
  puts "Validation passed!"
  p result.value # => validated and possibly transformed data
else
  puts "Validation failed:"
  result.errors.each do |error|
    puts "#{error[:path].join('.')}: #{error[:message]}"
  end
end
```

### Array Validation

```ruby
# Array of strings
tags_validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string)
  .min_items(1)
  .max_items(10)

# Array of objects
users_validator = RubyInputValidator::Schema.array(user_schema)

tags_result = tags_validator.validate(["ruby", "validator", "gem"])
```

### Nested Schemas

```ruby
address_schema = RubyInputValidator::Schema.object({
  street: RubyInputValidator::Schema.string,
  city: RubyInputValidator::Schema.string,
  postal_code: RubyInputValidator::Schema.string.pattern(/^\d{5}$/),
  country: RubyInputValidator::Schema.string
})

user_schema = RubyInputValidator::Schema.object({
  name: RubyInputValidator::Schema.string,
  email: RubyInputValidator::Schema.string.pattern(/\A[^@\s]+@[^@\s]+\z/),
  address: address_schema.optional
})
```

### Custom Error Messages

```ruby
validator = RubyInputValidator::Schema.string
  .min_length(8)
  .with_message("Password must be at least 8 characters long")

email_validator = RubyInputValidator::Schema.string
  .pattern(/\A[^@\s]+@[^@\s]+\z/)
  .with_message("Please provide a valid email address")
```

## API Reference

### String Validator

- `.min_length(n)` - Minimum string length
- `.max_length(n)` - Maximum string length  
- `.pattern(regex)` - Must match regular expression

### Number Validator

- `.min(n)` - Minimum value
- `.max(n)` - Maximum value
- `.integer` - Must be an integer

### Date Validator

- `.after(date)` - Must be after specified date
- `.before(date)` - Must be before specified date

### Array Validator

- `.min_items(n)` - Minimum number of items
- `.max_items(n)` - Maximum number of items

### All Validators

- `.optional` - Field is optional (allows nil/empty)
- `.with_message(msg)` - Custom error message

## Running the Example

```bash
cd task_8
ruby example.rb
```

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT). 