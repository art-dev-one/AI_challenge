require 'net/http'
require 'uri'
require 'json'

class ApiService
  BASE_URL = 'https://api.example.com'
  
  def initialize
    @timeout = 30
  end

  # Abstract method to be implemented by child classes
  def call(service_input)
    raise NotImplementedError, "Child classes must implement call method"
  end

  protected

  # Common HTTP request utility method for child classes
  def make_http_request(url, data, headers = {})
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    http.read_timeout = @timeout

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    headers.each { |key, value| request[key] = value }
    request.body = data.to_json

    response = http.request(request)
    
    {
      success: response.code.to_i == 200,
      body: response.body,
      code: response.code.to_i
    }
  rescue => e
    {
      success: false,
      error: e.message,
      code: 0
    }
  end

  # Common error handling method
  def handle_api_error(error_message, original_input)
    puts "\n" + "="*50
    puts "ERROR: Service Analysis Failed"
    puts "="*50
    puts "Message: #{error_message}"
    puts "Input: #{original_input}"
    puts "Time: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts "="*50 + "\n"
    nil
  end

  
end 