Gem::Specification.new do |spec|
  spec.name          = "ruby_input_validator"
  spec.version       = "0.1.0"
  spec.authors       = ["Your Name"]
  spec.email         = ["your.email@example.com"]
  
  spec.summary       = "A flexible schema validation library for Ruby"
  spec.description   = "Ruby Input Validator provides a clean, chainable API for validating data structures with custom error messages and complex validation rules."
  spec.homepage      = "https://github.com/yourusername/ruby_input_validator"
  spec.license       = "MIT"
  
  spec.files         = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]
  
  spec.required_ruby_version = ">= 3.3.0"
  
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
end 