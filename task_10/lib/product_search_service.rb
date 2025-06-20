require_relative 'openai_client'
require_relative 'database_connection'

class ProductSearchService
  def initialize
    @openai_client = OpenAIClient.new
    @db = DatabaseConnection.new
  end

  def search_with_ai(query)
    products_data = @db.all
    
    messages = [
      {
        role: 'system',
        content: "You are a product search assistant. You have access to a product database and can search through products based on user queries."
      },
      {
        role: 'user',
        content: query
      }
    ]

    functions = [
      {
        name: 'search_result',
        description: 'Search and filter products from the database based on user criteria and return matching products',
        parameters: {
          type: 'object',
          properties: {
            filtered_products: {
              type: 'array',
              description: 'Array of products that match the search criteria',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  category: { type: 'string' },
                  price: { type: 'number' },
                  rating: { type: 'number' },
                  in_stock: { type: 'boolean' }
                },
                required: ['name', 'category', 'price', 'rating', 'in_stock']
              }
            },
            search_criteria: {
              type: 'string',
              description: 'Brief description of the search criteria used'
            }
          },
          required: ['filtered_products', 'search_criteria']
        }
      }
    ]

    # Include the product data in the system message so OpenAI can search through it
    messages[0][:content] += "\n\nHere is the product database to search through:\n#{products_data.to_json}"

    response = @openai_client.function_calling(messages, functions)
    
    # Debug: Print the full response to understand the structure
    puts "DEBUG: Full API response: #{response.inspect}" if ENV['DEBUG']
    
    if response['error']
      puts "Error: #{response['error']}"
      return
    end

    # Check if response has the expected structure
    unless response['choices'] && response['choices'].is_a?(Array) && response['choices'].length > 0
      puts "Error: Unexpected API response structure. Response: #{response.inspect}"
      return
    end

    message = response['choices'][0]['message']
    
    unless message
      puts "Error: No message found in API response. Response: #{response.inspect}"
      return
    end
    
    if message['function_call']
      function_name = message['function_call']['name']
      
      unless message['function_call']['arguments']
        puts "Error: No function arguments found in API response."
        return
      end
      
      begin
        arguments = JSON.parse(message['function_call']['arguments'])
      rescue JSON::ParserError => e
        puts "Error parsing function arguments: #{e.message}"
        puts "Raw arguments: #{message['function_call']['arguments']}"
        return
      end
      
      if function_name == 'search_result'
        search_result(arguments)
      else
        puts "Unknown function called: #{function_name}"
      end
    else
      content = message['content'] || 'No content available'
      puts "OpenAI didn't call any function. Response: #{content}"
    end
  end

  private

  def search_result(params)
    puts "\n## Search Results"
    puts "\n**Search criteria:** #{params['search_criteria']}"
    puts "\n---"
    
    products = params['filtered_products']
    
    if products.empty?
      puts "\n❌ **No products found matching your criteria.**"
      return
    end

    puts "\n### 🛍️ Filtered Products:\n"
    products.each_with_index do |product, index|
      stock_status = product['in_stock'] ? '✅ In Stock' : '❌ Out of Stock'
      puts "#{index + 1}. **#{product['name']}**"
      puts "   - 💰 Price: $#{product['price']}"
      puts "   - ⭐ Rating: #{product['rating']}/5"
      puts "   - 📦 Status: #{stock_status}"
      puts "   - 🏷️ Category: #{product['category']}"
      puts ""
    end
    puts "---"
    puts "\n📊 **Total: #{products.length} product(s) found**"
  end
end 