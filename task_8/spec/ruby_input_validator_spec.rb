RSpec.describe RubyInputValidator do
  describe "VERSION" do
    it "has a version number" do
      expect(RubyInputValidator::VERSION).not_to be nil
    end
  end

  describe "Schema" do
    describe ".string" do
      it "validates strings" do
        validator = RubyInputValidator::Schema.string
        result = validator.validate("hello")
        
        expect(result).to be_valid
        expect(result.value).to eq("hello")
      end
      
      it "rejects non-strings" do
        validator = RubyInputValidator::Schema.string
        result = validator.validate(123)
        
        expect(result).not_to be_valid
        expect(result.errors.first[:message]).to include("Expected string")
      end
      
      it "validates min_length" do
        validator = RubyInputValidator::Schema.string.min_length(5)
        
        expect(validator.validate("hello")).to be_valid
        expect(validator.validate("hi")).not_to be_valid
      end
      
      it "validates max_length" do
        validator = RubyInputValidator::Schema.string.max_length(5)
        
        expect(validator.validate("hello")).to be_valid
        expect(validator.validate("hello world")).not_to be_valid
      end
      
      it "validates pattern" do
        validator = RubyInputValidator::Schema.string.pattern(/^[a-z]+$/)
        
        expect(validator.validate("hello")).to be_valid
        expect(validator.validate("Hello")).not_to be_valid
      end
      
      it "validates empty strings" do
        validator = RubyInputValidator::Schema.string
        
        expect(validator.validate("")).to be_valid
      end
      
      it "validates combined string constraints" do
        validator = RubyInputValidator::Schema.string
          .min_length(3).max_length(10).pattern(/^[a-zA-Z]+$/)
        
        expect(validator.validate("hello")).to be_valid
        expect(validator.validate("HelloWorld")).to be_valid
        expect(validator.validate("hi")).not_to be_valid  # too short
        expect(validator.validate("verylongstring")).not_to be_valid  # too long
        expect(validator.validate("hello123")).not_to be_valid  # pattern mismatch
      end
      
      it "validates edge case lengths" do
        validator = RubyInputValidator::Schema.string.min_length(0).max_length(0)
        
        expect(validator.validate("")).to be_valid
        expect(validator.validate("a")).not_to be_valid
      end
    end
    
    describe ".number" do
      it "validates numbers" do
        validator = RubyInputValidator::Schema.number
        
        expect(validator.validate(42)).to be_valid
        expect(validator.validate(3.14)).to be_valid
        expect(validator.validate("42")).not_to be_valid
      end
      
      it "validates min value" do
        validator = RubyInputValidator::Schema.number.min(10)
        
        expect(validator.validate(15)).to be_valid
        expect(validator.validate(5)).not_to be_valid
      end
      
      it "validates max value" do
        validator = RubyInputValidator::Schema.number.max(100)
        
        expect(validator.validate(50)).to be_valid
        expect(validator.validate(150)).not_to be_valid
      end
      
      it "validates integer only" do
        validator = RubyInputValidator::Schema.number.integer
        
        expect(validator.validate(42)).to be_valid
        expect(validator.validate(3.14)).not_to be_valid
      end
      
      it "validates zero and negative numbers" do
        validator = RubyInputValidator::Schema.number
        
        expect(validator.validate(0)).to be_valid
        expect(validator.validate(-42)).to be_valid
        expect(validator.validate(-3.14)).to be_valid
      end
      
      it "validates boundary values" do
        validator = RubyInputValidator::Schema.number.min(0).max(100)
        
        expect(validator.validate(0)).to be_valid  # exact min
        expect(validator.validate(100)).to be_valid  # exact max
        expect(validator.validate(-0.1)).not_to be_valid  # just below min
        expect(validator.validate(100.1)).not_to be_valid  # just above max
      end
      
      it "validates combined integer and range constraints" do
        validator = RubyInputValidator::Schema.number.integer.min(1).max(10)
        
        expect(validator.validate(5)).to be_valid
        expect(validator.validate(1)).to be_valid
        expect(validator.validate(10)).to be_valid
        expect(validator.validate(0)).not_to be_valid  # below min
        expect(validator.validate(11)).not_to be_valid  # above max
        expect(validator.validate(5.5)).not_to be_valid  # not integer
      end
    end
    
    describe ".boolean" do
      it "validates booleans" do
        validator = RubyInputValidator::Schema.boolean
        
        expect(validator.validate(true)).to be_valid
        expect(validator.validate(false)).to be_valid
        expect(validator.validate("true")).not_to be_valid
      end
      
      it "rejects truthy/falsy values that aren't actual booleans" do
        validator = RubyInputValidator::Schema.boolean
        
        expect(validator.validate(1)).not_to be_valid
        expect(validator.validate(0)).not_to be_valid
        expect(validator.validate("")).not_to be_valid
        expect(validator.validate(nil)).not_to be_valid
        expect(validator.validate([])).not_to be_valid
        expect(validator.validate({})).not_to be_valid
      end
    end
    
    describe ".date" do
      it "validates dates" do
        validator = RubyInputValidator::Schema.date
        
        expect(validator.validate(Date.today)).to be_valid
        expect(validator.validate("2023-01-01")).to be_valid
        expect(validator.validate("invalid")).not_to be_valid
      end
      
      it "validates Time and DateTime objects" do
        validator = RubyInputValidator::Schema.date
        
        expect(validator.validate(Time.now)).to be_valid
        expect(validator.validate(DateTime.now)).to be_valid
      end
      
      it "validates after constraint" do
        past_date = Date.new(2020, 1, 1)
        validator = RubyInputValidator::Schema.date.after(past_date)
        
        expect(validator.validate(Date.new(2020, 1, 2))).to be_valid
        expect(validator.validate(Date.new(2019, 12, 31))).not_to be_valid
        expect(validator.validate(past_date)).not_to be_valid
      end
      
      it "validates before constraint" do
        future_date = Date.new(2030, 12, 31)
        validator = RubyInputValidator::Schema.date.before(future_date)
        
        expect(validator.validate(Date.new(2030, 12, 30))).to be_valid
        expect(validator.validate(Date.new(2031, 1, 1))).not_to be_valid
        expect(validator.validate(future_date)).not_to be_valid
      end
      
      it "validates combined after and before constraints" do
        start_date = Date.new(2023, 1, 1)
        end_date = Date.new(2023, 12, 31)
        validator = RubyInputValidator::Schema.date.after(start_date).before(end_date)
        
        expect(validator.validate(Date.new(2023, 6, 15))).to be_valid
        expect(validator.validate(Date.new(2022, 12, 31))).not_to be_valid
        expect(validator.validate(Date.new(2024, 1, 1))).not_to be_valid
      end
    end
    
    describe ".array" do
      it "validates arrays" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string)
        
        expect(validator.validate(["hello", "world"])).to be_valid
        expect(validator.validate(["hello", 123])).not_to be_valid
      end
      
      it "validates min_items" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string).min_items(2)
        
        expect(validator.validate(["hello", "world"])).to be_valid
        expect(validator.validate(["hello"])).not_to be_valid
      end
      
      it "validates max_items" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string).max_items(2)
        
        expect(validator.validate(["hello", "world"])).to be_valid
        expect(validator.validate(["hello", "world", "foo"])).not_to be_valid
      end
      
      it "validates combined min and max items" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string)
          .min_items(1).max_items(3)
        
        expect(validator.validate(["hello"])).to be_valid
        expect(validator.validate(["hello", "world"])).to be_valid
        expect(validator.validate(["hello", "world", "foo"])).to be_valid
        expect(validator.validate([])).not_to be_valid
        expect(validator.validate(["a", "b", "c", "d"])).not_to be_valid
      end
      
      it "validates empty arrays" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.string)
        
        expect(validator.validate([])).to be_valid
      end
      
      it "provides correct error paths for nested array validation" do
        validator = RubyInputValidator::Schema.array(RubyInputValidator::Schema.number.min(0))
        result = validator.validate([1, -5, 3])
        
        expect(result).not_to be_valid
        expect(result.errors.length).to eq(1)
        expect(result.errors.first[:path]).to eq([1])
        expect(result.errors.first[:message]).to include("at least 0")
      end
    end
    
    describe ".object" do
      it "validates objects" do
        validator = RubyInputValidator::Schema.object({
          name: RubyInputValidator::Schema.string,
          age: RubyInputValidator::Schema.number
        })
        
        data = { name: "John", age: 30 }
        expect(validator.validate(data)).to be_valid
        
        invalid_data = { name: "John", age: "thirty" }
        expect(validator.validate(invalid_data)).not_to be_valid
      end
      
      it "handles different key formats (symbol vs string)" do
        validator = RubyInputValidator::Schema.object({
          name: RubyInputValidator::Schema.string,
          age: RubyInputValidator::Schema.number
        })
        
        # Symbol keys
        expect(validator.validate({ name: "John", age: 30 })).to be_valid
        
        # String keys
        expect(validator.validate({ "name" => "John", "age" => 30 })).to be_valid
        
        # Mixed keys
        expect(validator.validate({ :name => "John", "age" => 30 })).to be_valid
      end
      
      it "validates empty objects" do
        validator = RubyInputValidator::Schema.object({})
        
        expect(validator.validate({})).to be_valid
      end
      
      it "provides correct error paths for nested object validation" do
        validator = RubyInputValidator::Schema.object({
          user: RubyInputValidator::Schema.object({
            name: RubyInputValidator::Schema.string.min_length(2)
          })
        })
        
        result = validator.validate({ user: { name: "J" } })
        
        expect(result).not_to be_valid
        expect(result.errors.first[:path]).to eq([:user, :name])
        expect(result.errors.first[:message]).to include("at least 2")
      end
      
      it "rejects non-hash values" do
        validator = RubyInputValidator::Schema.object({})
        
        expect(validator.validate("not a hash")).not_to be_valid
        expect(validator.validate([])).not_to be_valid
        expect(validator.validate(123)).not_to be_valid
      end
    end
    
    describe "optional fields" do
      it "allows nil values for optional fields" do
        validator = RubyInputValidator::Schema.string.optional
        
        expect(validator.validate(nil)).to be_valid
        expect(validator.validate("")).to be_valid
        expect(validator.validate("hello")).to be_valid
      end
      
      it "works with all validator types" do
        expect(RubyInputValidator::Schema.number.optional.validate(nil)).to be_valid
        expect(RubyInputValidator::Schema.boolean.optional.validate(nil)).to be_valid
        expect(RubyInputValidator::Schema.date.optional.validate(nil)).to be_valid
        expect(RubyInputValidator::Schema.array(RubyInputValidator::Schema.string).optional.validate(nil)).to be_valid
        expect(RubyInputValidator::Schema.object({}).optional.validate(nil)).to be_valid
      end
      
      it "still validates non-nil values normally" do
        validator = RubyInputValidator::Schema.string.min_length(5).optional
        
        expect(validator.validate(nil)).to be_valid
        expect(validator.validate("hello")).to be_valid
        expect(validator.validate("hi")).not_to be_valid  # too short
      end
    end
    
    describe "custom messages" do
      it "uses custom error messages" do
        validator = RubyInputValidator::Schema.string.with_message("Custom error message")
        result = validator.validate(123)
        
        expect(result).not_to be_valid
        expect(result.errors.first[:message]).to eq("Custom error message")
      end
      
      it "works with chained validations" do
        validator = RubyInputValidator::Schema.string.min_length(5).with_message("Must be at least 5 chars")
        result = validator.validate("hi")
        
        expect(result).not_to be_valid
        expect(result.errors.first[:message]).to eq("Must be at least 5 chars")
      end
      
      it "applies custom messages to optional fields" do
        validator = RubyInputValidator::Schema.string.min_length(5).optional.with_message("Custom message")
        result = validator.validate("hi")
        
        expect(result).not_to be_valid
        expect(result.errors.first[:message]).to eq("Custom message")
      end
    end
    
    describe "complex schema" do
      it "validates nested schemas like the original example" do
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

        result = user_schema.validate(user_data)
        expect(result).to be_valid
      end
    end
    
    describe "ValidationResult" do
      it "properly implements valid? and invalid? methods" do
        valid_result = RubyInputValidator::Schema.string.validate("hello")
        invalid_result = RubyInputValidator::Schema.string.validate(123)
        
        expect(valid_result.valid?).to be true
        expect(valid_result.invalid?).to be false
        
        expect(invalid_result.valid?).to be false
        expect(invalid_result.invalid?).to be true
      end
      
      it "contains the correct value for successful validation" do
        result = RubyInputValidator::Schema.string.validate("hello")
        
        expect(result.valid?).to be true
        expect(result.value).to eq("hello")
        expect(result.errors).to be_empty
      end
      
      it "contains errors for failed validation" do
        result = RubyInputValidator::Schema.string.min_length(10).validate("hi")
        
        expect(result.invalid?).to be true
        expect(result.value).to be_nil
        expect(result.errors).not_to be_empty
        expect(result.errors.first).to have_key(:path)
        expect(result.errors.first).to have_key(:message)
      end
    end
    
    describe "Edge Cases" do
      it "handles multiple validation errors in objects" do
        validator = RubyInputValidator::Schema.object({
          name: RubyInputValidator::Schema.string.min_length(2),
          age: RubyInputValidator::Schema.number.min(0),
          email: RubyInputValidator::Schema.string.pattern(/\A[^@\s]+@[^@\s]+\z/)
        })
        
        result = validator.validate({
          name: "J",           # too short
          age: -5,             # negative
          email: "invalid"     # wrong format
        })
        
        expect(result).not_to be_valid
        expect(result.errors.length).to eq(3)
        expect(result.errors.map { |e| e[:path] }).to contain_exactly([:name], [:age], [:email])
      end
      
      it "handles deeply nested validation errors" do
        validator = RubyInputValidator::Schema.object({
          users: RubyInputValidator::Schema.array(
            RubyInputValidator::Schema.object({
              profile: RubyInputValidator::Schema.object({
                name: RubyInputValidator::Schema.string.min_length(2)
              })
            })
          )
        })
        
        result = validator.validate({
          users: [
            { profile: { name: "John" } },   # valid
            { profile: { name: "J" } }       # invalid - too short
          ]
        })
        
        expect(result).not_to be_valid
        expect(result.errors.first[:path]).to eq([:users, 1, :profile, :name])
      end
      
      it "handles nil and empty values consistently" do
        string_validator = RubyInputValidator::Schema.string
        
        # Non-optional should reject nil
        expect(string_validator.validate(nil)).not_to be_valid
        
        # But accept empty string
        expect(string_validator.validate("")).to be_valid
      end
      
      it "validates method chaining order independence" do
        # These should produce equivalent validators
        validator1 = RubyInputValidator::Schema.string.min_length(3).max_length(10).optional
        validator2 = RubyInputValidator::Schema.string.optional.min_length(3).max_length(10)
        validator3 = RubyInputValidator::Schema.string.max_length(10).optional.min_length(3)
        
        test_values = [nil, "", "hi", "hello", "verylongstring"]
        
        test_values.each do |value|
          result1 = validator1.validate(value)
          result2 = validator2.validate(value)
          result3 = validator3.validate(value)
          
          expect(result1.valid?).to eq(result2.valid?), "Failed for value: #{value.inspect}"
          expect(result1.valid?).to eq(result3.valid?), "Failed for value: #{value.inspect}"
        end
      end
    end
  end
end 