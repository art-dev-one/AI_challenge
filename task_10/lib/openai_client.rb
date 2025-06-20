require 'net/http'
require 'json'
require 'uri'
require 'dotenv/load'

class OpenAIClient
  BASE_URL = 'https://api.openai.com/v1'
  
  def initialize
    @api_key = ENV['OPENAI_API_KEY']
    
    if @api_key.nil? || @api_key.empty?
      raise "OPENAI_API_KEY not found in environment variables. Please check your .env file."
    end
  end

  def function_calling(messages, functions, model: 'gpt-4.1-mini', temperature: 0.7)
    endpoint = '/chat/completions'
    
    payload = {
      model: model,
      messages: messages,
      functions: functions,
      function_call: 'auto',
      temperature: temperature
    }
    
    make_request(endpoint, payload)
  end

  private

  def make_request(endpoint, payload)
    uri = URI("#{BASE_URL}#{endpoint}")
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{@api_key}"
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json
    
    response = http.request(request)
    
    case response.code.to_i
    when 200..299
      JSON.parse(response.body)
    else
      handle_error_response(response)
    end
  rescue StandardError => e
    { error: "Request failed: #{e.message}" }
  end

  def handle_error_response(response)
    error_body = JSON.parse(response.body) rescue {}
    error_message = error_body.dig('error', 'message') || 'Unknown error'
    
    {
      error: "OpenAI API Error (#{response.code}): #{error_message}",
      status_code: response.code.to_i
    }
  end
end
