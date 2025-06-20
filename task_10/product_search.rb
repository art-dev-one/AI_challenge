require_relative 'lib/database_connection'
require_relative 'lib/product_search_service'

# Create an instance of DatabaseConnection when the file loads
@database_connection = DatabaseConnection.new

# Create an instance of ProductSearchService
@search_service = ProductSearchService.new

puts "🛍️  AI-Powered Product Search"
puts "=" * 40
puts "Enter your search query (e.g., 'I need a smartphone under $800 with good rating'):"
puts "Type 'exit' to quit"
puts

loop do
  print "> "
  user_input = gets.chomp
  
  break if user_input.downcase == 'exit'
  
  if user_input.strip.empty?
    puts "Please enter a search query."
    next
  end
  
  puts "\n🤖 Processing your request with AI..."
  @search_service.search_with_ai(user_input)
  
  puts "\n" + "=" * 40
  puts "Enter another search query or 'exit' to quit:"
end

puts "Thank you for using AI-Powered Product Search! 👋"
